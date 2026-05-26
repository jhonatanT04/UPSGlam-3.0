package com.ups.upsglam_backend.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Publicacion {

    private Long id;

    @JsonProperty("usuario_id")
    private UUID usuarioId;

    @JsonProperty("imagen_url")
    private String imagenUrl;

    @JsonProperty("imagen_original_url")
    private String imagenOriginalUrl;

    private String descripcion;

    @JsonProperty("creado_en")
    private ZonedDateTime creadoEn;

    // Embedded por PostgREST al hacer ?select=*,perfiles(username,avatar_url)
    private Perfil perfiles;
}
