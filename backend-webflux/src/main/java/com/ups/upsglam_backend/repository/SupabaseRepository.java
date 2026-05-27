package com.ups.upsglam_backend.repository;

import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.DefaultUriBuilderFactory;

/**
 * Base para todos los repositorios que hablan con Supabase REST API.
 * Provee dos WebClient: uno con service key (bypass RLS) y
 * otro que acepta el JWT del usuario (respeta RLS).
 *
 * EncodingMode.NONE evita que WebClient codifique los paréntesis de
 * los operadores PostgREST como in.(1,2,3), que de otro modo se
 * convierten en %281%2C2%29 y producen 400 Bad Request en Supabase.
 */
public abstract class SupabaseRepository {

    protected final WebClient serviceClient;
    protected final String supabaseKey;
    protected final String supabaseUrl;

    protected SupabaseRepository(String supabaseUrl, String supabaseKey) {
        this.supabaseUrl = supabaseUrl;
        this.supabaseKey = supabaseKey;

        DefaultUriBuilderFactory factory =
                new DefaultUriBuilderFactory(supabaseUrl + "/rest/v1");
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);

        this.serviceClient = WebClient.builder()
                .uriBuilderFactory(factory)
                .defaultHeader("apikey", supabaseKey)
                .defaultHeader("Authorization", "Bearer " + supabaseKey)
                .defaultHeader("Content-Type", "application/json")
                .build();
    }

    /** WebClient con el JWT del usuario (respeta RLS). */
    protected WebClient userClient(String userJwt) {
        DefaultUriBuilderFactory factory =
                new DefaultUriBuilderFactory(supabaseUrl + "/rest/v1");
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);

        return WebClient.builder()
                .uriBuilderFactory(factory)
                .defaultHeader("apikey", supabaseKey)
                .defaultHeader("Authorization", "Bearer " + userJwt)
                .defaultHeader("Content-Type", "application/json")
                .build();
    }
}
