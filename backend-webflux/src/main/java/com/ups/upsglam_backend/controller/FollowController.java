package com.ups.upsglam_backend.controller;

import com.ups.upsglam_backend.dto.UserSearchResult;
import com.ups.upsglam_backend.service.FollowService;
import com.ups.upsglam_backend.util.JwtUtils;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@CrossOrigin(origins = "*")
public class FollowController {

    private final FollowService followService;

    public FollowController(FollowService followService) {
        this.followService = followService;
    }

    @PostMapping("/follow/{targetId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> follow(
            @PathVariable UUID targetId,
            @RequestHeader("Authorization") String bearer) {
        return followService.follow(JwtUtils.extractUserId(bearer), targetId);
    }

    @DeleteMapping("/follow/{targetId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> unfollow(
            @PathVariable UUID targetId,
            @RequestHeader("Authorization") String bearer) {
        return followService.unfollow(JwtUtils.extractUserId(bearer), targetId);
    }

    @GetMapping("/perfil/search")
    public Mono<List<UserSearchResult>> searchUsers(
            @RequestParam String q,
            @RequestHeader("Authorization") String bearer) {
        return followService.searchUsers(q, JwtUtils.extractUserId(bearer));
    }
}
