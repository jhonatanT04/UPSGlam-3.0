package com.ups.upsglam_backend.controller;

import com.ups.upsglam_backend.dto.PerfilResponse;
import com.ups.upsglam_backend.service.PerfilService;
import com.ups.upsglam_backend.util.JwtUtils;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@CrossOrigin(origins = "*")
public class PerfilController {

    private final PerfilService perfilService;

    public PerfilController(PerfilService perfilService) {
        this.perfilService = perfilService;
    }

    /** Perfil por UUID explícito. */
    @GetMapping("/perfil/{userId}")
    public Mono<PerfilResponse> getPerfil(@PathVariable UUID userId) {
        return perfilService.getPerfil(userId);
    }

    /** Perfil del usuario autenticado (extrae ID del JWT). */
    @GetMapping("/perfil/me")
    public Mono<PerfilResponse> getMyPerfil(
            @RequestHeader("Authorization") String bearer) {
        UUID userId = JwtUtils.extractUserId(bearer);
        return perfilService.getPerfil(userId);
    }
}
