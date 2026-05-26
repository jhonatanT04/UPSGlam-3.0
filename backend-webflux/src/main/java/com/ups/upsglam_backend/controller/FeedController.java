package com.ups.upsglam_backend.controller;

import com.ups.upsglam_backend.dto.PublicacionRequest;
import com.ups.upsglam_backend.dto.PublicacionResponse;
import com.ups.upsglam_backend.service.FeedService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@CrossOrigin(origins = "*")
public class FeedController {

    private final FeedService feedService;

    public FeedController(FeedService feedService) {
        this.feedService = feedService;
    }

    /** Feed público — el JWT es opcional (si se envía, marca is_liked). */
    @GetMapping("/api/v1/feed")
    public Flux<PublicacionResponse> getFeed(
            @RequestHeader(value = "Authorization", required = false) String bearer) {
        return feedService.getFeed(bearer);
    }

    /** Crear publicación — requiere JWT. */
    @PostMapping("/api/v1/publicaciones")
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<PublicacionResponse> createPublicacion(
            @RequestBody PublicacionRequest req,
            @RequestHeader("Authorization") String bearer) {
        return feedService.createPublicacion(req, bearer);
    }
}
