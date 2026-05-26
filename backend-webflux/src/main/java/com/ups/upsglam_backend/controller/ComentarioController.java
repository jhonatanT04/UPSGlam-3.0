package com.ups.upsglam_backend.controller;

import com.ups.upsglam_backend.dto.ComentarioRequest;
import com.ups.upsglam_backend.dto.ComentarioResponse;
import com.ups.upsglam_backend.service.ComentarioService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/v1/publicaciones/{publicacionId}")
@CrossOrigin(origins = "*")
public class ComentarioController {

    private final ComentarioService comentarioService;

    public ComentarioController(ComentarioService comentarioService) {
        this.comentarioService = comentarioService;
    }

    @GetMapping("/comentarios")
    public Flux<ComentarioResponse> getComentarios(@PathVariable Long publicacionId) {
        return comentarioService.getComentarios(publicacionId);
    }

    @PostMapping("/comentarios")
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<ComentarioResponse> addComentario(
            @PathVariable Long publicacionId,
            @RequestBody ComentarioRequest req,
            @RequestHeader("Authorization") String bearer) {
        return comentarioService.addComentario(publicacionId, req, bearer);
    }

    @PostMapping("/like")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> toggleLike(
            @PathVariable Long publicacionId,
            @RequestHeader("Authorization") String bearer) {
        return comentarioService.toggleLike(publicacionId, bearer);
    }
}
