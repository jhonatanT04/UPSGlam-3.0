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
}
