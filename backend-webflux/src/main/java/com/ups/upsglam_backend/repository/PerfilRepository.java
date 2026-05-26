package com.ups.upsglam_backend.repository;

import com.ups.upsglam_backend.model.Perfil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public class PerfilRepository extends SupabaseRepository {

    public PerfilRepository(
            @Value("${supabase.url}") String supabaseUrl,
            @Value("${supabase.key}") String supabaseKey) {
        super(supabaseUrl, supabaseKey);
    }

    public Mono<Perfil> findById(UUID id) {
        return serviceClient.get()
                .uri(u -> u.path("/perfiles")
                        .queryParam("id", "eq." + id)
                        .queryParam("limit", "1")
                        .build())
                .retrieve()
                .bodyToFlux(Perfil.class)
                .next();
    }

    public Mono<Void> create(UUID id, String username) {
        return serviceClient.post()
                .uri("/perfiles")
                .header("Prefer", "return=minimal")
                .bodyValue(java.util.Map.of("id", id.toString(), "username", username))
                .retrieve()
                .toBodilessEntity()
                .then();
    }

    public Mono<Perfil> findByUsername(String username) {
        return serviceClient.get()
                .uri(u -> u.path("/perfiles")
                        .queryParam("username", "eq." + username)
                        .queryParam("limit",    "1")
                        .build())
                .retrieve()
                .bodyToFlux(Perfil.class)
                .next();
    }

    public Mono<Perfil> update(UUID id, String username, String avatarUrl) {
        java.util.Map<String, Object> body = new java.util.HashMap<>();
        if (username  != null) body.put("username",   username);
        if (avatarUrl != null) body.put("avatar_url", avatarUrl);

        return serviceClient.patch()
                .uri(u -> u.path("/perfiles")
                        .queryParam("id", "eq." + id)
                        .build())
                .header("Prefer", "return=representation")
                .bodyValue(body)
                .retrieve()
                .bodyToFlux(Perfil.class)
                .next();
    }
}
