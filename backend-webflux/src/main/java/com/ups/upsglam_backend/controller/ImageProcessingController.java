package com.ups.upsglam_backend.controller;

import com.ups.upsglam_backend.dto.GpuProcessResponse;
import com.ups.upsglam_backend.model.HistorialGpu;
import com.ups.upsglam_backend.repository.HistorialGpuRepository;
import com.ups.upsglam_backend.service.ImageProcessingService;
import com.ups.upsglam_backend.service.SupabaseStorageService;
import com.ups.upsglam_backend.util.JwtUtils;
import org.springframework.http.MediaType;
import org.springframework.http.codec.multipart.FilePart;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

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
            @RequestPart("file") Mono<FilePart> filePartMono,
            @RequestHeader(value = "Authorization", required = false) String bearer) {

        return filePartMono.flatMap(filePart ->
            imageProcessingService.procesarImagenEnGpu(filterName, filterSize, filePart)
                .flatMap(gpuResponse -> {
                    if ("Exito".equals(gpuResponse.getEstado())) {
                        return supabaseStorageService
                                .subirImagenBase64(gpuResponse.getImagenProcesadaB64(), filePart.filename())
                                .flatMap(publicUrl -> {
                                    gpuResponse.setUrlImagenProcesada(publicUrl);
                                    gpuResponse.setImagenProcesadaB64(null);

                                    HistorialGpu historial = new HistorialGpu();
                                    historial.setUsuarioId(JwtUtils.extractUserId(bearer));
                                    historial.setFiltroAplicado(gpuResponse.getFiltroAplicado());
                                    historial.setTamanoImagen(gpuResponse.getTamanoImagen());
                                    historial.setDimensionBloque(gpuResponse.getDimensionBloque());
                                    historial.setDimensionGrid(gpuResponse.getDimensionGrid());
                                    historial.setTotalHilos(gpuResponse.getTotalHilos());
                                    historial.setTiempoEjecucionMs(gpuResponse.getTiempoEjecucionMs());
                                    historial.setEstado(gpuResponse.getEstado());

                                    return historialGpuRepository.save(historial)
                                            .thenReturn(gpuResponse)
                                            .onErrorResume(e -> {
                                                System.err.println("Advertencia historial: " + e.getMessage());
                                                return Mono.just(gpuResponse);
                                            });
                                });
                    }
                    return Mono.just(gpuResponse);
                })
        );
    }
}
