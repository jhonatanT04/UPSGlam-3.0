package com.ups.upsglam_backend.repository;

import com.ups.upsglam_backend.model.Like;
import com.ups.upsglam_backend.model.Publicacion;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.net.URI;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
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
                .uri(URI.create(supabaseUrl
                        + "/rest/v1/publicaciones?select=*,perfiles!publicaciones_usuario_id_fkey(id,username,avatar_url)"
                        + "&order=creado_en.desc&limit=50"))
                .retrieve()
                .bodyToFlux(Publicacion.class);
    }

    /** Publicaciones de un usuario específico. */
    public Flux<Publicacion> findByUsuarioId(UUID usuarioId) {
        return serviceClient.get()
                .uri(URI.create(supabaseUrl
                        + "/rest/v1/publicaciones?select=*,perfiles!publicaciones_usuario_id_fkey(id,username,avatar_url)"
                        + "&usuario_id=eq." + usuarioId
                        + "&order=creado_en.desc"))
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
        if (ids.isEmpty()) return Flux.empty();
        String inClause = ids.stream().map(String::valueOf)
                .collect(Collectors.joining(",", "(", ")"));
        String url = supabaseUrl + "/rest/v1/likes?publicacion_id=in." + inClause
                + "&select=publicacion_id,usuario_id";
        log.debug("findLikesByPublicacionIds URL: {}", url);
        return serviceClient.get()
                .uri(URI.create(url))
                .retrieve()
                .onStatus(status -> !status.is2xxSuccessful(), response ->
                        response.bodyToMono(String.class)
                                .doOnNext(body -> log.error("Supabase likes error {}: {}", response.statusCode(), body))
                                .flatMap(body -> Mono.error(new RuntimeException(body))))
                .bodyToFlux(Like.class)
                .onErrorResume(e -> { log.error("likes flux error: {}", e.getMessage()); return Flux.empty(); });
    }

    /** Mapa de publicacion_id → cantidad de likes. */
    public Mono<Map<Long, Long>> countLikesByIds(List<Long> ids) {
        if (ids.isEmpty()) return Mono.just(Map.of());
        return findLikesByPublicacionIds(ids)
                .collectList()
                .map(likes -> likes.stream()
                        .collect(Collectors.groupingBy(
                                Like::getPublicacionId, Collectors.counting())))
                .onErrorReturn(Map.of());
    }

    /** Set de publicacion_id que el usuario ha dado like. */
    public Mono<Set<Long>> likedByUser(List<Long> ids, UUID userId) {
        if (ids.isEmpty()) return Mono.just(Set.of());
        String inClause = ids.stream().map(String::valueOf)
                .collect(Collectors.joining(",", "(", ")"));
        String url = supabaseUrl + "/rest/v1/likes?publicacion_id=in." + inClause
                + "&usuario_id=eq." + userId
                + "&select=publicacion_id";
        return serviceClient.get()
                .uri(URI.create(url))
                .retrieve()
                .onStatus(status -> !status.is2xxSuccessful(), response ->
                        response.bodyToMono(String.class)
                                .doOnNext(body -> log.error("Supabase likedByUser error {}: {}", response.statusCode(), body))
                                .flatMap(body -> Mono.error(new RuntimeException(body))))
                .bodyToFlux(Like.class)
                .map(Like::getPublicacionId)
                .collect(Collectors.toSet())
                .onErrorReturn(Set.of());
    }
}
