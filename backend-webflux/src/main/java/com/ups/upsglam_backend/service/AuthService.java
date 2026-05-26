package com.ups.upsglam_backend.service;

import com.ups.upsglam_backend.dto.AuthResponse;
import com.ups.upsglam_backend.dto.LoginRequest;
import com.ups.upsglam_backend.dto.RegisterRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ResponseStatusException;
import reactor.core.publisher.Mono;

import java.util.Map;

@Service
public class AuthService {

    private final WebClient authClient;

    public AuthService(@Value("${supabase.url}") String supabaseUrl,
                       @Value("${supabase.key}") String supabaseKey) {
        this.authClient = WebClient.builder()
                .baseUrl(supabaseUrl + "/auth/v1")
                .defaultHeader("apikey", supabaseKey)
                .defaultHeader("Content-Type", "application/json")
                .build();
    }

    public Mono<AuthResponse> register(RegisterRequest req) {
        Map<String, Object> body = Map.of(
                "email", req.getEmail(),
                "password", req.getPassword(),
                "data", Map.of("username", req.getUsername())
        );
        return authClient.post()
                .uri("/signup")
                .bodyValue(body)
                .retrieve()
                .onStatus(status -> status.is4xxClientError(),
                        r -> r.bodyToMono(String.class)
                                .map(msg -> new ResponseStatusException(HttpStatus.BAD_REQUEST, msg)))
                .bodyToMono(AuthResponse.class);
    }

    public Mono<AuthResponse> login(LoginRequest req) {
        Map<String, Object> body = Map.of(
                "email", req.getEmail(),
                "password", req.getPassword()
        );
        return authClient.post()
                .uri("/token?grant_type=password")
                .bodyValue(body)
                .retrieve()
                .onStatus(status -> status.is4xxClientError(),
                        r -> r.bodyToMono(String.class)
                                .map(msg -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Credenciales inválidas")))
                .bodyToMono(AuthResponse.class);
    }

    public Mono<Void> logout(String userJwt) {
        return authClient.post()
                .uri("/logout")
                .header("Authorization", "Bearer " + userJwt)
                .retrieve()
                .toBodilessEntity()
                .then();
    }
}
