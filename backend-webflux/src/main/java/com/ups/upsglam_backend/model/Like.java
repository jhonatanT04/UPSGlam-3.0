package com.ups.upsglam_backend.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.UUID;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Like {

    private Long id;

    @JsonProperty("publicacion_id")
    private Long publicacionId;

    @JsonProperty("usuario_id")
    private UUID usuarioId;
}
