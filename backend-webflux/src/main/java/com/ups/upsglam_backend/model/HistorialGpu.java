package com.ups.upsglam_backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;
import com.fasterxml.jackson.annotation.JsonInclude;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class HistorialGpu {
    
    private Long id;
    
    @JsonProperty("usuario_id")
    private UUID usuarioId;
    
    @JsonProperty("filtro_aplicado")
    private String filtroAplicado;
    
    @JsonProperty("tamano_imagen")
    private String tamanoImagen;
    
    @JsonProperty("dimension_bloque")
    private String dimensionBloque;
    
    @JsonProperty("dimension_grid")
    private String dimensionGrid;
    
    @JsonProperty("total_hilos")
    private Integer totalHilos;
    
    @JsonProperty("tiempo_ejecucion_ms")
    private BigDecimal tiempoEjecucionMs;
    
    private String estado;
    
    @JsonProperty("creado_en")
    private ZonedDateTime creadoEn;
}