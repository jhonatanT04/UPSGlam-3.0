package com.ups.upsglam_backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class PublicacionRequest {
    @JsonProperty("imagen_url")
    private String imagenUrl;

    @JsonProperty("imagen_original_url")
    private String imagenOriginalUrl;

    private String descripcion;
}
