package com.ups.upsglam_backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class PublicacionResponse {

    private Long id;

    @JsonProperty("usuario_id")
    private UUID usuarioId;

    private String username;

    @JsonProperty("avatar_url")
    private String avatarUrl;

    @JsonProperty("imagen_url")
    private String imagenUrl;

    @JsonProperty("imagen_original_url")
    private String imagenOriginalUrl;

    private String descripcion;

    @JsonProperty("likes_count")
    private long likesCount;

    @JsonProperty("comentarios_count")
    private long comentariosCount;

    @JsonProperty("is_liked")
    private boolean isLiked;

    @JsonProperty("creado_en")
    private ZonedDateTime creadoEn;
}
