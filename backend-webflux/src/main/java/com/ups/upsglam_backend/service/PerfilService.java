package com.ups.upsglam_backend.service;

import com.ups.upsglam_backend.dto.PerfilResponse;
import com.ups.upsglam_backend.dto.PublicacionResponse;
import com.ups.upsglam_backend.dto.UpdatePerfilRequest;
import com.ups.upsglam_backend.model.Perfil;
import com.ups.upsglam_backend.model.Publicacion;
import com.ups.upsglam_backend.repository.ComentarioRepository;
import com.ups.upsglam_backend.repository.FollowRepository;
import com.ups.upsglam_backend.repository.PerfilRepository;
import com.ups.upsglam_backend.repository.PublicacionRepository;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class PerfilService {

    private final PerfilRepository perfilRepo;
    private final PublicacionRepository publicacionRepo;
    private final ComentarioRepository comentarioRepo;
    private final FollowRepository followRepo;

    public PerfilService(PerfilRepository perfilRepo,
                         PublicacionRepository publicacionRepo,
                         ComentarioRepository comentarioRepo,
                         FollowRepository followRepo) {
        this.perfilRepo      = perfilRepo;
        this.publicacionRepo = publicacionRepo;
        this.comentarioRepo  = comentarioRepo;
        this.followRepo      = followRepo;
    }

    public Mono<Perfil> updatePerfil(UUID userId, UpdatePerfilRequest req) {
        return perfilRepo.update(userId, req.getUsername(), req.getAvatarUrl());
    }

    public Mono<PerfilResponse> getPerfil(UUID userId) {
        return Mono.zip(
                perfilRepo.findById(userId),
                publicacionRepo.findByUsuarioId(userId).collectList(),
                followRepo.countFollowers(userId),
                followRepo.countFollowing(userId)
        ).flatMap(t -> {
            var perfil              = t.getT1();
            List<Publicacion> posts = t.getT2();
            long seguidores         = t.getT3();
            long seguidos           = t.getT4();

            if (posts.isEmpty()) {
                return Mono.just(buildResponse(perfil, posts,
                        Collections.emptyMap(), Collections.emptyMap(),
                        seguidores, seguidos));
            }

            List<Long> ids = posts.stream().map(Publicacion::getId)
                    .filter(java.util.Objects::nonNull).toList();

            if (ids.isEmpty()) {
                return Mono.just(buildResponse(perfil, posts,
                        Collections.emptyMap(), Collections.emptyMap(),
                        seguidores, seguidos));
            }

            return Mono.zip(
                    publicacionRepo.countLikesByIds(ids),
                    comentarioRepo.countByPublicacionIds(ids)
            ).map(counts -> buildResponse(perfil, posts,
                    counts.getT1(), counts.getT2(), seguidores, seguidos));
        });
    }

    private PerfilResponse buildResponse(Perfil perfil,
                                          List<Publicacion> posts,
                                          Map<Long, Long> likes,
                                          Map<Long, Long> comentarios,
                                          long seguidores,
                                          long seguidos) {
        long totalLikes = likes.values().stream().mapToLong(Long::longValue).sum();

        List<PublicacionResponse> postResponses = posts.stream()
                .map(p -> PublicacionResponse.builder()
                        .id(p.getId())
                        .usuarioId(p.getUsuarioId())
                        .username(perfil.getUsername())
                        .avatarUrl(perfil.getAvatarUrl())
                        .imagenUrl(p.getImagenUrl())
                        .imagenOriginalUrl(p.getImagenOriginalUrl())
                        .descripcion(p.getDescripcion())
                        .likesCount(p.getId() != null ? likes.getOrDefault(p.getId(), 0L) : 0L)
                        .comentariosCount(p.getId() != null ? comentarios.getOrDefault(p.getId(), 0L) : 0L)
                        .isLiked(false)
                        .creadoEn(p.getCreadoEn())
                        .build())
                .toList();

        return PerfilResponse.builder()
                .id(perfil.getId())
                .username(perfil.getUsername())
                .avatarUrl(perfil.getAvatarUrl())
                .publicacionesCount(posts.size())
                .totalLikes(totalLikes)
                .seguidores(seguidores)
                .seguidos(seguidos)
                .publicaciones(postResponses)
                .build();
    }
}
