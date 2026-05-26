package com.ups.upsglam_backend.repository;

import com.ups.upsglam_backend.model.HistorialGpu;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Repository
public class HistorialGpuRepository {

    private final WebClient webClient;
    private final String supabaseKey;

    public HistorialGpuRepository(
            @Value("${supabase.url}") String supabaseUrl,
            @Value("${supabase.key}") String supabaseKey) {
        
        this.supabaseKey = supabaseKey;
        // Inicializamos el WebClient directamente sin depender de Spring Beans
        this.webClient = WebClient.create(supabaseUrl + "/rest/v1");
    }

    public Mono<HistorialGpu> save(HistorialGpu historial) {
        return this.webClient.post()
                .uri("/historial_gpu")
                .header("apikey", supabaseKey)
                .header("Authorization", "Bearer " + supabaseKey)
                .header("Content-Type", "application/json")
                .header("Prefer", "return=representation") // Fuerza a Supabase a retornar el objeto creado
                .bodyValue(historial)
                .retrieve()
                .bodyToFlux(HistorialGpu.class)
                .next(); // Extrae el objeto guardado del flujo reactivo
    }
}