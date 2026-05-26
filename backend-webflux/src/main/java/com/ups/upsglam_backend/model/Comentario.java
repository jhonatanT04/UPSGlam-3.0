package com.ups.upsglam_backend.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Comentario {

    private Long id;

    @JsonProperty("publicacion_id")
    private Long publicacionId;

    @JsonProperty("usuario_id")
    private UUID usuarioId;

    private String texto;

    @JsonProperty("creado_en")
    private ZonedDateTime creadoEn;

    // Embedded por PostgREST
    private Perfil perfiles;
}
