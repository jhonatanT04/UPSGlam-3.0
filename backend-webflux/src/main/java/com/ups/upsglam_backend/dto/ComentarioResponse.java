package com.ups.upsglam_backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class ComentarioResponse {

    private Long id;

    @JsonProperty("publicacion_id")
    private Long publicacionId;

    @JsonProperty("usuario_id")
    private UUID usuarioId;

    private String username;

    @JsonProperty("avatar_url")
    private String avatarUrl;

    private String texto;

    @JsonProperty("creado_en")
    private ZonedDateTime creadoEn;
}
