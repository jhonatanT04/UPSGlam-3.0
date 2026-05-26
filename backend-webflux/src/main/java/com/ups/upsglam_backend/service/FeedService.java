package com.ups.upsglam_backend.service;

import com.ups.upsglam_backend.dto.PublicacionRequest;
import com.ups.upsglam_backend.dto.PublicacionResponse;
import com.ups.upsglam_backend.model.Publicacion;
import com.ups.upsglam_backend.repository.ComentarioRepository;
import com.ups.upsglam_backend.repository.PublicacionRepository;
import com.ups.upsglam_backend.util.JwtUtils;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class FeedService {

    private final PublicacionRepository publicacionRepo;
    private final ComentarioRepository comentarioRepo;

    public FeedService(PublicacionRepository publicacionRepo,
                       ComentarioRepository comentarioRepo) {
        this.publicacionRepo = publicacionRepo;
        this.comentarioRepo  = comentarioRepo;
    }

    public Flux<PublicacionResponse> getFeed(String bearerHeader) {
        UUID userId = bearerHeader != null ? JwtUtils.extractUserId(bearerHeader) : null;

        return publicacionRepo.findAll()
                .collectList()
                .flatMapMany(publicaciones -> {
                    if (publicaciones.isEmpty()) return Flux.empty();

                    List<Long> ids = publicaciones.stream()
                            .map(Publicacion::getId).toList();

                    Mono<Map<Long, Long>> likesCounts =
                            publicacionRepo.countLikesByIds(ids);
                    Mono<Map<Long, Long>> comentariosCounts =
                            comentarioRepo.countByPublicacionIds(ids);
                    Mono<Set<Long>> likedByUser = userId != null
                            ? publicacionRepo.likedByUser(ids, userId)
                            : Mono.just(Collections.emptySet());

                    return Mono.zip(likesCounts, comentariosCounts, likedByUser)
                            .flatMapMany(t -> Flux.fromIterable(publicaciones)
                                    .map(p -> toResponse(p, t.getT1(), t.getT2(), t.getT3())));
                });
    }

    public Mono<PublicacionResponse> createPublicacion(PublicacionRequest req, String bearerHeader) {
        UUID userId = JwtUtils.extractUserId(bearerHeader);
        String jwt  = JwtUtils.extractToken(bearerHeader);

        Publicacion p = new Publicacion();
        p.setUsuarioId(userId);
        p.setImagenUrl(req.getImagenUrl());
        p.setImagenOriginalUrl(req.getImagenOriginalUrl());
        p.setDescripcion(req.getDescripcion());

        return publicacionRepo.save(p, jwt)
                .map(saved -> toResponse(saved,
                        Collections.emptyMap(),
                        Collections.emptyMap(),
                        Collections.emptySet()));
    }

    private PublicacionResponse toResponse(Publicacion p,
                                            Map<Long, Long> likes,
                                            Map<Long, Long> comentarios,
                                            Set<Long> likedIds) {
        String username  = p.getPerfiles() != null ? p.getPerfiles().getUsername()  : null;
        String avatarUrl = p.getPerfiles() != null ? p.getPerfiles().getAvatarUrl() : null;

        return PublicacionResponse.builder()
                .id(p.getId())
                .usuarioId(p.getUsuarioId())
                .username(username)
                .avatarUrl(avatarUrl)
                .imagenUrl(p.getImagenUrl())
                .imagenOriginalUrl(p.getImagenOriginalUrl())
                .descripcion(p.getDescripcion())
                .likesCount(likes.getOrDefault(p.getId(), 0L))
                .comentariosCount(comentarios.getOrDefault(p.getId(), 0L))
                .isLiked(likedIds.contains(p.getId()))
                .creadoEn(p.getCreadoEn())
                .build();
    }
}
