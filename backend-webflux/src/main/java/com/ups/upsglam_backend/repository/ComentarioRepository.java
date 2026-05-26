package com.ups.upsglam_backend.repository;

import com.ups.upsglam_backend.model.Comentario;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Repository
public class ComentarioRepository extends SupabaseRepository {

    public ComentarioRepository(
            @Value("${supabase.url}") String supabaseUrl,
            @Value("${supabase.key}") String supabaseKey) {
        super(supabaseUrl, supabaseKey);
    }

    public Flux<Comentario> findByPublicacionId(Long publicacionId) {
        return serviceClient.get()
                .uri(u -> u.path("/comentarios")
                        .queryParam("select", "*,perfiles(id,username,avatar_url)")
                        .queryParam("publicacion_id", "eq." + publicacionId)
                        .queryParam("order", "creado_en.asc")
                        .build())
                .retrieve()
                .bodyToFlux(Comentario.class);
    }

    /** Mapa de publicacion_id → cantidad de comentarios para una lista de IDs. */
    public Mono<Map<Long, Long>> countByPublicacionIds(List<Long> ids) {
        String inClause = ids.stream().map(String::valueOf)
                .collect(Collectors.joining(",", "(", ")"));
        return serviceClient.get()
                .uri(u -> u.path("/comentarios")
                        .queryParam("publicacion_id", "in." + inClause)
                        .queryParam("select", "publicacion_id")
                        .build())
                .retrieve()
                .bodyToFlux(Comentario.class)
                .collectList()
                .map(list -> list.stream()
                        .collect(Collectors.groupingBy(
                                Comentario::getPublicacionId, Collectors.counting())));
    }

    public Mono<Comentario> save(Comentario comentario, String userJwt) {
        return userClient(userJwt).post()
                .uri("/comentarios")
                .header("Prefer", "return=representation")
                .bodyValue(comentario)
                .retrieve()
                .bodyToFlux(Comentario.class)
                .next();
    }

    /** Actualiza el usuario_id en historial_gpu para enlazar con el usuario autenticado. */
    public Mono<Void> updateUsuarioHistorial(Long historialId, UUID usuarioId) {
        return serviceClient.patch()
                .uri(u -> u.path("/historial_gpu")
                        .queryParam("id", "eq." + historialId)
                        .build())
                .bodyValue(Map.of("usuario_id", usuarioId.toString()))
                .retrieve()
                .toBodilessEntity()
                .then();
    }
}
