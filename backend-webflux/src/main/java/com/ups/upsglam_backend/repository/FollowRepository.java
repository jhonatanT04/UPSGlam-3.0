package com.ups.upsglam_backend.repository;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Repository
public class FollowRepository extends SupabaseRepository {

    public FollowRepository(
            @Value("${supabase.url}") String supabaseUrl,
            @Value("${supabase.key}") String supabaseKey) {
        super(supabaseUrl, supabaseKey);
    }

    public Mono<Void> follow(UUID followerId, UUID followingId) {
        return serviceClient.post()
                .uri("/follows")
                .header("Prefer", "return=minimal")
                .bodyValue(Map.of(
                        "follower_id",  followerId.toString(),
                        "following_id", followingId.toString()))
                .retrieve()
                .toBodilessEntity()
                .then();
    }

    public Mono<Void> unfollow(UUID followerId, UUID followingId) {
        return serviceClient.delete()
                .uri(u -> u.path("/follows")
                        .queryParam("follower_id",  "eq." + followerId)
                        .queryParam("following_id", "eq." + followingId)
                        .build())
                .retrieve()
                .toBodilessEntity()
                .then();
    }

    public Mono<Long> countFollowers(UUID userId) {
        return serviceClient.get()
                .uri(u -> u.path("/follows")
                        .queryParam("following_id", "eq." + userId)
                        .queryParam("select", "follower_id")
                        .build())
                .retrieve()
                .bodyToFlux(Map.class)
                .count();
    }

    public Mono<Long> countFollowing(UUID userId) {
        return serviceClient.get()
                .uri(u -> u.path("/follows")
                        .queryParam("follower_id", "eq." + userId)
                        .queryParam("select", "following_id")
                        .build())
                .retrieve()
                .bodyToFlux(Map.class)
                .count();
    }

    public Mono<Boolean> isFollowing(UUID followerId, UUID followingId) {
        return serviceClient.get()
                .uri(u -> u.path("/follows")
                        .queryParam("follower_id",  "eq." + followerId)
                        .queryParam("following_id", "eq." + followingId)
                        .queryParam("select", "follower_id")
                        .queryParam("limit", "1")
                        .build())
                .retrieve()
                .bodyToFlux(Map.class)
                .hasElements();
    }

    public Mono<Set<UUID>> getFollowingIds(UUID userId) {
        return serviceClient.get()
                .uri(u -> u.path("/follows")
                        .queryParam("follower_id", "eq." + userId)
                        .queryParam("select", "following_id")
                        .build())
                .retrieve()
                .bodyToFlux(Map.class)
                .map(m -> UUID.fromString((String) m.get("following_id")))
                .collect(Collectors.toSet());
    }
}
