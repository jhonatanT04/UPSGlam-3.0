package com.ups.upsglam_backend.repository;

import com.ups.upsglam_backend.model.Like;
import com.ups.upsglam_backend.model.Publicacion;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Repository
public class PublicacionRepository extends SupabaseRepository {

    public PublicacionRepository(
            @Value("${supabase.url}") String supabaseUrl,
            @Value("${supabase.key}") String supabaseKey) {
        super(supabaseUrl, supabaseKey);
    }

    /** Feed: todas las publicaciones con perfil del autor, ordenadas por fecha. */
    public Flux<Publicacion> findAll() {
        return serviceClient.get()
                .uri("/publicaciones?select=*,perfiles(id,username,avatar_url)&order=creado_en.desc&limit=50")
                .retrieve()
                .bodyToFlux(Publicacion.class);
    }

    /** Publicaciones de un usuario específico. */
    public Flux<Publicacion> findByUsuarioId(UUID usuarioId) {
        return serviceClient.get()
                .uri(u -> u.path("/publicaciones")
                        .queryParam("select", "*,perfiles(id,username,avatar_url)")
                        .queryParam("usuario_id", "eq." + usuarioId)
                        .queryParam("order", "creado_en.desc")
                        .build())
                .retrieve()
                .bodyToFlux(Publicacion.class);
    }

    /** Crear publicación (requiere JWT del usuario para RLS). */
    public Mono<Publicacion> save(Publicacion publicacion, String userJwt) {
        return userClient(userJwt).post()
                .uri("/publicaciones")
                .header("Prefer", "return=representation")
                .bodyValue(publicacion)
                .retrieve()
                .bodyToFlux(Publicacion.class)
                .next();
    }

    // ── Likes ────────────────────────────────────────────

    /** Todos los likes para una lista de publicaciones. */
    public Flux<Like> findLikesByPublicacionIds(List<Long> ids) {
        String inClause = ids.stream().map(String::valueOf)
                .collect(Collectors.joining(",", "(", ")"));
        return serviceClient.get()
                .uri(u -> u.path("/likes")
                        .queryParam("publicacion_id", "in." + inClause)
                        .queryParam("select", "publicacion_id,usuario_id")
                        .build())
                .retrieve()
                .bodyToFlux(Like.class);
    }

    /** Mapa de publicacion_id → cantidad de likes. */
    public Mono<Map<Long, Long>> countLikesByIds(List<Long> ids) {
        return findLikesByPublicacionIds(ids)
                .collectList()
                .map(likes -> likes.stream()
                        .collect(Collectors.groupingBy(
                                Like::getPublicacionId, Collectors.counting())));
    }

    /** Set de publicacion_id que el usuario ha dado like. */
    public Mono<java.util.Set<Long>> likedByUser(List<Long> ids, UUID userId) {
        String inClause = ids.stream().map(String::valueOf)
                .collect(Collectors.joining(",", "(", ")"));
        return serviceClient.get()
                .uri(u -> u.path("/likes")
                        .queryParam("publicacion_id", "in." + inClause)
                        .queryParam("usuario_id", "eq." + userId)
                        .queryParam("select", "publicacion_id")
                        .build())
                .retrieve()
                .bodyToFlux(Like.class)
                .map(Like::getPublicacionId)
                .collect(java.util.stream.Collectors.toSet());
    }
}
