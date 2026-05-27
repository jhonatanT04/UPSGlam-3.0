package com.ups.upsglam_backend.service;

import com.ups.upsglam_backend.dto.AuthResponse;
import com.ups.upsglam_backend.dto.ForgotPasswordRequest;
import com.ups.upsglam_backend.dto.LoginRequest;
import com.ups.upsglam_backend.dto.RegisterRequest;
import com.ups.upsglam_backend.repository.PerfilRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ResponseStatusException;
import reactor.core.publisher.Mono;

import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class AuthService {

    private static final Pattern MSG_PATTERN =
            Pattern.compile("\"msg\"\\s*:\\s*\"([^\"]+)\"");
    private static final Pattern MESSAGE_PATTERN =
            Pattern.compile("\"message\"\\s*:\\s*\"([^\"]+)\"");

    private final WebClient authClient;
    private final WebClient adminClient;
    private final PerfilRepository perfilRepository;

    public AuthService(@Value("${supabase.url}") String supabaseUrl,
                       @Value("${supabase.key}") String supabaseKey,
                       PerfilRepository perfilRepository) {
        this.authClient = WebClient.builder()
                .baseUrl(supabaseUrl + "/auth/v1")
                .defaultHeader("apikey", supabaseKey)
                .defaultHeader("Content-Type", "application/json")
                .build();
        this.adminClient = WebClient.builder()
                .baseUrl(supabaseUrl + "/auth/v1")
                .defaultHeader("apikey", supabaseKey)
                .defaultHeader("Authorization", "Bearer " + supabaseKey)
                .defaultHeader("Content-Type", "application/json")
                .build();
        this.perfilRepository = perfilRepository;
    }

    private String extractSupabaseError(String body) {
        Matcher m = MSG_PATTERN.matcher(body);
        if (m.find()) return m.group(1);
        m = MESSAGE_PATTERN.matcher(body);
        if (m.find()) return m.group(1);
        return "Error de autenticación";
    }

    private String toSpanish(String englishMsg) {
        if (englishMsg == null) return "Error de autenticación";
        String lower = englishMsg.toLowerCase();
        if (lower.contains("already registered") || lower.contains("already exists"))
            return "Este correo ya está registrado";
        if (lower.contains("invalid email"))
            return "El correo no es válido";
        if (lower.contains("weak password") || lower.contains("password should be"))
            return "La contraseña debe tener al menos 6 caracteres";
        if (lower.contains("signup") && lower.contains("disabled"))
            return "El registro está deshabilitado temporalmente";
        if (lower.contains("rate limit") || lower.contains("too many"))
            return "Demasiados intentos, espera unos minutos";
        return englishMsg;
    }

    private Mono<Throwable> supabaseError(String body, HttpStatus status) {
        return Mono.error(new ResponseStatusException(status, toSpanish(extractSupabaseError(body))));
    }

    public Mono<AuthResponse> register(RegisterRequest req) {
        return authClient.post()
                .uri("/signup")
                .bodyValue(Map.of("email", req.getEmail(), "password", req.getPassword()))
                .retrieve()
                .onStatus(s -> s.is4xxClientError() || s.is5xxServerError(),
                        r -> r.bodyToMono(String.class).flatMap(b -> supabaseError(b, HttpStatus.BAD_REQUEST)))
                .bodyToMono(AuthResponse.class)
                .flatMap(authResponse -> {
                    if (authResponse.getUser() == null || authResponse.getUser().getId() == null) {
                        return Mono.just(authResponse);
                    }
                    String username = req.getEmail().split("@")[0];
                    return perfilRepository
                            .create(authResponse.getUser().getId(), username)
                            .thenReturn(authResponse)
                            .onErrorResume(e -> {
                                System.err.println("Advertencia al crear perfil: " + e.getMessage());
                                return Mono.just(authResponse);
                            });
                });
    }

    public Mono<AuthResponse> login(LoginRequest req) {
        Mono<String> emailMono = req.getIdentifier().contains("@")
                ? Mono.just(req.getIdentifier())
                : perfilRepository.findByUsername(req.getIdentifier())
                        .switchIfEmpty(Mono.error(new ResponseStatusException(
                                HttpStatus.UNAUTHORIZED, "Usuario/correo o contraseña inválidos")))
                        .flatMap(perfil -> adminClient.get()
                                .uri("/admin/users/" + perfil.getId())
                                .retrieve()
                                .bodyToMono(Map.class)
                                .map(user -> (String) user.get("email"))
                                .filter(e -> e != null && !e.isBlank())
                                .switchIfEmpty(Mono.error(new ResponseStatusException(
                                        HttpStatus.UNAUTHORIZED, "Usuario/correo o contraseña inválidos"))));

        return emailMono.flatMap(email ->
                authClient.post()
                        .uri("/token?grant_type=password")
                        .bodyValue(Map.of("email", email, "password", req.getPassword()))
                        .retrieve()
                        .onStatus(s -> s.is4xxClientError() || s.is5xxServerError(),
                                r -> r.bodyToMono(String.class).flatMap(b ->
                                        Mono.error(new ResponseStatusException(
                                                HttpStatus.UNAUTHORIZED, "Usuario/correo o contraseña inválidos"))))
                        .bodyToMono(AuthResponse.class)
        );
    }

    public Mono<Void> forgotPassword(ForgotPasswordRequest req) {
        Mono<String> emailMono = req.getIdentifier().contains("@")
                ? Mono.just(req.getIdentifier())
                : perfilRepository.findByUsername(req.getIdentifier())
                        .switchIfEmpty(Mono.error(new ResponseStatusException(
                                HttpStatus.NOT_FOUND, "No existe ninguna cuenta con ese usuario o correo")))
                        .flatMap(perfil -> adminClient.get()
                                .uri("/admin/users/" + perfil.getId())
                                .retrieve()
                                .bodyToMono(Map.class)
                                .map(user -> (String) user.get("email"))
                                .filter(e -> e != null && !e.isBlank())
                                .switchIfEmpty(Mono.error(new ResponseStatusException(
                                        HttpStatus.NOT_FOUND, "No existe ninguna cuenta con ese usuario o correo"))));

        return emailMono.flatMap(email ->
                authClient.post()
                        .uri("/recover")
                        .bodyValue(Map.of("email", email))
                        .retrieve()
                        .onStatus(s -> s.value() == 429,
                                r -> Mono.error(new ResponseStatusException(
                                        HttpStatus.TOO_MANY_REQUESTS,
                                        "Demasiados intentos, espera unos minutos antes de volver a intentarlo")))
                        .onStatus(s -> s.is4xxClientError() || s.is5xxServerError(),
                                r -> r.bodyToMono(String.class).flatMap(b -> supabaseError(b, HttpStatus.BAD_REQUEST)))
                        .toBodilessEntity()
                        .then());
    }

    public Mono<Void> logout(String userJwt) {
        return authClient.post()
                .uri("/logout")
                .header("Authorization", "Bearer " + userJwt)
                .retrieve()
                .toBodilessEntity()
                .then()
                .onErrorResume(e -> Mono.empty());
    }
}
