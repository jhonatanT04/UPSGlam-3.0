package com.ups.upsglam_backend.controller;

import com.ups.upsglam_backend.dto.GpuProcessResponse;
import com.ups.upsglam_backend.model.HistorialGpu;
import com.ups.upsglam_backend.repository.HistorialGpuRepository;
import com.ups.upsglam_backend.service.ImageProcessingService;
import com.ups.upsglam_backend.service.SupabaseStorageService;
import org.springframework.http.MediaType;
import org.springframework.http.codec.multipart.FilePart;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.time.ZonedDateTime;

@RestController
@RequestMapping("/api/v1/images")
@CrossOrigin(origins = "*")
public class ImageProcessingController {

    private final ImageProcessingService imageProcessingService;
    private final SupabaseStorageService supabaseStorageService;
    private final HistorialGpuRepository historialGpuRepository;

    public ImageProcessingController(
            ImageProcessingService imageProcessingService, 
            SupabaseStorageService supabaseStorageService,
            HistorialGpuRepository historialGpuRepository) {
        this.imageProcessingService = imageProcessingService;
        this.supabaseStorageService = supabaseStorageService;
        this.historialGpuRepository = historialGpuRepository;
    }

    @PostMapping(
        value = "/process/{filterName}", 
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE, 
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    public Mono<GpuProcessResponse> processImage(
            @PathVariable String filterName,
            @RequestParam(defaultValue = "65") int filterSize,
            @RequestPart("file") Mono<FilePart> filePartMono) {
        
        return filePartMono.flatMap(filePart -> 
            imageProcessingService.procesarImagenEnGpu(filterName, filterSize, filePart)
                .flatMap(gpuResponse -> {
                    if ("Exito".equals(gpuResponse.getEstado())) {
                        return supabaseStorageService.subirImagenBase64(gpuResponse.getImagenProcesadaB64(), filePart.filename())
                            .flatMap(publicUrl -> {
                                gpuResponse.setUrlImagenProcesada(publicUrl);
                                gpuResponse.setImagenProcesadaB64(null); // Limpiar Base64
                                
                                // GUARDAR EN POSTGRESQL VÍA REST (HISTORIAL GPU)
                                HistorialGpu historial = new HistorialGpu();
                                
                                // 1. Enviamos null ya que modificamos la base para aceptarlo temporalmente
                                historial.setUsuarioId(null); 
                                
                                historial.setFiltroAplicado(gpuResponse.getFiltroAplicado());
                                historial.setTamanoImagen(gpuResponse.getTamanoImagen());
                                historial.setDimensionBloque(gpuResponse.getDimensionBloque());
                                historial.setDimensionGrid(gpuResponse.getDimensionGrid());
                                historial.setTotalHilos(gpuResponse.getTotalHilos());
                                
                                // Aseguramos mantener la métrica estrictamente en ms
                                historial.setTiempoEjecucionMs(gpuResponse.getTiempoEjecucionMs()); 
                                
                                historial.setEstado(gpuResponse.getEstado());
                                //historial.setCreadoEn(ZonedDateTime.now());

                                // 2. save() hace el POST asíncrono a la API REST de Supabase
                                return historialGpuRepository.save(historial)
                                        .thenReturn(gpuResponse)
                                        .onErrorResume(e -> {
                                            // 3. Resiliencia: Si falla el registro, devolvemos la imagen de todas formas
                                            System.err.println("Advertencia: No se pudo guardar el historial vía REST: " + e.getMessage());
                                            return Mono.just(gpuResponse);
                                        });
                            });
                    }
                    return Mono.just(gpuResponse);
                })
        );
    }
}