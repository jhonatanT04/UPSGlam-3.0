package com.ups.upsglam_backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class GpuProcessResponse {
    private String estado;
    
    @JsonProperty("filtro_aplicado")
    private String filtroAplicado;
    
    @JsonProperty("tamaño_filtro_usado")
    private String tamanoFiltroUsado;
    
    @JsonProperty("tamaño_imagen")
    private String tamanoImagen;
    
    @JsonProperty("dimension_bloque")
    private String dimensionBloque;
    
    @JsonProperty("dimension_grid")
    private String dimensionGrid;
    
    @JsonProperty("total_hilos")
    private Integer totalHilos;
    
    @JsonProperty("tiempo_ejecucion_ms")
    private BigDecimal tiempoEjecucionMs;
    
    @JsonProperty("imagen_procesada_b64")
    private String imagenProcesadaB64;

    @JsonProperty("url_imagen_procesada")
    private String urlImagenProcesada;
}
