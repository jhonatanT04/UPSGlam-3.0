package com.ups.upsglam_backend.service;

import com.ups.upsglam_backend.dto.PerfilResponse;
import com.ups.upsglam_backend.dto.PublicacionResponse;
import com.ups.upsglam_backend.model.Publicacion;
import com.ups.upsglam_backend.repository.ComentarioRepository;
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

    public PerfilService(PerfilRepository perfilRepo,
                         PublicacionRepository publicacionRepo,
                         ComentarioRepository comentarioRepo) {
        this.perfilRepo      = perfilRepo;
        this.publicacionRepo = publicacionRepo;
        this.comentarioRepo  = comentarioRepo;
    }

    public Mono<PerfilResponse> getPerfil(UUID userId) {
        return Mono.zip(
                perfilRepo.findById(userId),
                publicacionRepo.findByUsuarioId(userId).collectList()
        ).flatMap(t -> {
            var perfil       = t.getT1();
            List<Publicacion> posts = t.getT2();

            if (posts.isEmpty()) {
                return Mono.just(buildResponse(perfil, posts,
                        Collections.emptyMap(), Collections.emptyMap()));
            }

            List<Long> ids = posts.stream().map(Publicacion::getId).toList();

            return Mono.zip(
                    publicacionRepo.countLikesByIds(ids),
                    comentarioRepo.countByPublicacionIds(ids)
            ).map(counts -> buildResponse(perfil, posts, counts.getT1(), counts.getT2()));
        });
    }

    private PerfilResponse buildResponse(com.ups.upsglam_backend.model.Perfil perfil,
                                          List<Publicacion> posts,
                                          Map<Long, Long> likes,
                                          Map<Long, Long> comentarios) {
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
                        .likesCount(likes.getOrDefault(p.getId(), 0L))
                        .comentariosCount(comentarios.getOrDefault(p.getId(), 0L))
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
                .publicaciones(postResponses)
                .build();
    }
}
