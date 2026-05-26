package com.ups.upsglam_backend.repository;

import org.springframework.web.reactive.function.client.WebClient;

/**
 * Base para todos los repositorios que hablan con Supabase REST API.
 * Provee dos WebClient: uno con service key (bypass RLS) y
 * otro que acepta el JWT del usuario (respeta RLS).
 */
public abstract class SupabaseRepository {

    protected final WebClient serviceClient;
    protected final String supabaseKey;
    protected final String supabaseUrl;

    protected SupabaseRepository(String supabaseUrl, String supabaseKey) {
        this.supabaseUrl = supabaseUrl;
        this.supabaseKey = supabaseKey;
        this.serviceClient = WebClient.builder()
                .baseUrl(supabaseUrl + "/rest/v1")
                .defaultHeader("apikey", supabaseKey)
                .defaultHeader("Authorization", "Bearer " + supabaseKey)
                .defaultHeader("Content-Type", "application/json")
                .build();
    }

    /** WebClient con el JWT del usuario (respeta RLS). */
    protected WebClient userClient(String userJwt) {
        return WebClient.builder()
                .baseUrl(supabaseUrl + "/rest/v1")
                .defaultHeader("apikey", supabaseKey)
                .defaultHeader("Authorization", "Bearer " + userJwt)
                .defaultHeader("Content-Type", "application/json")
                .build();
    }
}
