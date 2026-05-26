package com.ups.upsglam_backend.service;

import com.ups.upsglam_backend.dto.GpuProcessResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.MediaType;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.http.codec.multipart.FilePart;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
public class ImageProcessingService {

    private final WebClient webClient;

    public ImageProcessingService(@Value("${PYTHON_SERVICE_URL:http://localhost:8000}") String pythonServiceUrl) {
        this.webClient = WebClient.builder().baseUrl(pythonServiceUrl).build();
    }

    public Mono<GpuProcessResponse> procesarImagenEnGpu(String filterName, int filterSize, FilePart filePart) {
        MultipartBodyBuilder builder = new MultipartBodyBuilder();
        
        builder.asyncPart("file", filePart.content(), DataBuffer.class)
               .filename(filePart.filename());

        return webClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path("/api/v1/process/{filter_name}")
                        .queryParam("filter_size", filterSize)
                        .build(filterName))
                .contentType(MediaType.MULTIPART_FORM_DATA)
                .body(BodyInserters.fromMultipartData(builder.build()))
                .retrieve()
                .bodyToMono(GpuProcessResponse.class);
    }
}
