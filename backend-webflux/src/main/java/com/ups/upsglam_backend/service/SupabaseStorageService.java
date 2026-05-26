package com.ups.upsglam_backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.Base64;
import java.util.UUID;

@Service
public class SupabaseStorageService {

    private final WebClient webClient;
    private final String supabaseUrl;
    private final String bucketName = "upsglam-images";

    public SupabaseStorageService(
            @Value("${supabase.url}") String supabaseUrl,
            @Value("${supabase.key}") String supabaseKey) {
        this.supabaseUrl = supabaseUrl;
        this.webClient = WebClient.builder()
                .baseUrl(supabaseUrl)
                .defaultHeader("Authorization", "Bearer " + supabaseKey)
                .defaultHeader("apikey", supabaseKey)
                .build();
    }

    public Mono<String> subirImagenBase64(String base64Image, String originalFilename) {
        return Mono.fromCallable(() -> Base64.getDecoder().decode(base64Image))
            .flatMap(imageBytes -> {
                String extension = originalFilename.contains(".") ? originalFilename.substring(originalFilename.lastIndexOf(".")) : ".jpg";
                String uniqueFilename = UUID.randomUUID().toString() + extension;

                return webClient.post()
                        .uri("/storage/v1/object/" + bucketName + "/" + uniqueFilename)
                        .contentType(MediaType.IMAGE_JPEG)
                        .bodyValue(imageBytes)
                        .retrieve()
                        .toBodilessEntity()
                        .map(entity -> supabaseUrl + "/storage/v1/object/public/" + bucketName + "/" + uniqueFilename);
            });
    }
}
