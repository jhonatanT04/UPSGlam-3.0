package com.ups.upsglam_backend.repository;

import com.ups.upsglam_backend.model.Like;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public class LikeRepository extends SupabaseRepository {

    public LikeRepository(
            @Value("${supabase.url}") String supabaseUrl,
            @Value("${supabase.key}") String supabaseKey) {
        super(supabaseUrl, supabaseKey);
    }

    public Mono<Boolean> exists(Long publicacionId, UUID usuarioId) {
        return serviceClient.get()
                .uri(u -> u.path("/likes")
                        .queryParam("publicacion_id", "eq." + publicacionId)
                        .queryParam("usuario_id", "eq." + usuarioId)
                        .queryParam("select", "id")
                        .queryParam("limit", "1")
                        .build())
                .retrieve()
                .bodyToFlux(Like.class)
                .hasElements();
    }

    public Mono<Void> save(Long publicacionId, UUID usuarioId) {
        Like like = new Like();
        like.setPublicacionId(publicacionId);
        like.setUsuarioId(usuarioId);
        return serviceClient.post()
                .uri("/likes")
                .bodyValue(like)
                .retrieve()
                .toBodilessEntity()
                .then();
    }

    public Mono<Void> delete(Long publicacionId, UUID usuarioId) {
        return serviceClient.delete()
                .uri(u -> u.path("/likes")
                        .queryParam("publicacion_id", "eq." + publicacionId)
                        .queryParam("usuario_id", "eq." + usuarioId)
                        .build())
                .retrieve()
                .toBodilessEntity()
                .then();
    }
}
