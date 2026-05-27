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

    @GetMapping("/api/v1/feed")
    public Flux<PublicacionResponse> getFeed(
            @RequestHeader(value = "Authorization", required = false) String bearer) {
        return feedService.getFeed(bearer);
    }

    @PostMapping("/api/v1/publicaciones")
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<PublicacionResponse> createPublicacion(
            @RequestBody PublicacionRequest req,
            @RequestHeader("Authorization") String bearer) {
        return feedService.createPublicacion(req, bearer);
    }

    @PostMapping("/api/v1/publicaciones/{id}/like")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> addLike(
            @PathVariable Long id,
            @RequestHeader("Authorization") String bearer) {
        return feedService.addLike(id, bearer);
    }

    @DeleteMapping("/api/v1/publicaciones/{id}/like")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> removeLike(
            @PathVariable Long id,
            @RequestHeader("Authorization") String bearer) {
        return feedService.removeLike(id, bearer);
    }
}
