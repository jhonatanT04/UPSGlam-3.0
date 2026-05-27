package com.ups.upsglam_backend.service;

import com.ups.upsglam_backend.dto.ComentarioRequest;
import com.ups.upsglam_backend.dto.ComentarioResponse;
import com.ups.upsglam_backend.model.Comentario;
import com.ups.upsglam_backend.repository.ComentarioRepository;
import com.ups.upsglam_backend.repository.LikeRepository;
import com.ups.upsglam_backend.util.JwtUtils;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Service
public class ComentarioService {

    private final ComentarioRepository comentarioRepo;
    private final LikeRepository likeRepo;

    public ComentarioService(ComentarioRepository comentarioRepo,
                              LikeRepository likeRepo) {
        this.comentarioRepo = comentarioRepo;
        this.likeRepo       = likeRepo;
    }

    public Flux<ComentarioResponse> getComentarios(Long publicacionId) {
        return comentarioRepo.findByPublicacionId(publicacionId)
                .map(this::toResponse);
    }

    public Mono<ComentarioResponse> addComentario(Long publicacionId,
                                                   ComentarioRequest req,
                                                   String bearerHeader) {
        UUID userId = JwtUtils.extractUserId(bearerHeader);

        Comentario c = new Comentario();
        c.setPublicacionId(publicacionId);
        c.setUsuarioId(userId);
        c.setTexto(req.getTexto());

        return comentarioRepo.save(c).map(this::toResponse);
    }

    public Mono<Void> toggleLike(Long publicacionId, String bearerHeader) {
        UUID userId = JwtUtils.extractUserId(bearerHeader);

        return likeRepo.exists(publicacionId, userId)
                .flatMap(exists -> exists
                        ? likeRepo.delete(publicacionId, userId)
                        : likeRepo.save(publicacionId, userId));
    }

    private ComentarioResponse toResponse(Comentario c) {
        String username  = c.getPerfiles() != null ? c.getPerfiles().getUsername()  : null;
        String avatarUrl = c.getPerfiles() != null ? c.getPerfiles().getAvatarUrl() : null;
        return ComentarioResponse.builder()
                .id(c.getId())
                .publicacionId(c.getPublicacionId())
                .usuarioId(c.getUsuarioId())
                .username(username)
                .avatarUrl(avatarUrl)
                .texto(c.getTexto())
                .creadoEn(c.getCreadoEn())
                .build();
    }
}
