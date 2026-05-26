package com.ups.upsglam_backend.service;

import com.ups.upsglam_backend.dto.UserSearchResult;
import com.ups.upsglam_backend.repository.FollowRepository;
import com.ups.upsglam_backend.repository.PerfilRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.UUID;

@Service
public class FollowService {

    private final FollowRepository followRepo;
    private final PerfilRepository perfilRepo;

    public FollowService(FollowRepository followRepo, PerfilRepository perfilRepo) {
        this.followRepo = followRepo;
        this.perfilRepo = perfilRepo;
    }

    public Mono<Void> follow(UUID currentUserId, UUID targetId) {
        if (currentUserId.equals(targetId)) {
            return Mono.error(new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "No puedes seguirte a ti mismo"));
        }
        return followRepo.follow(currentUserId, targetId);
    }

    public Mono<Void> unfollow(UUID currentUserId, UUID targetId) {
        return followRepo.unfollow(currentUserId, targetId);
    }

    public Mono<List<UserSearchResult>> searchUsers(String query, UUID currentUserId) {
        if (query == null || query.isBlank()) {
            return Mono.just(List.of());
        }
        return Mono.zip(
                followRepo.getFollowingIds(currentUserId),
                perfilRepo.searchByUsernamePrefix(query).collectList()
        ).map(t -> t.getT2().stream()
                .filter(p -> !p.getId().equals(currentUserId))
                .map(p -> new UserSearchResult(
                        p.getId(),
                        p.getUsername(),
                        p.getAvatarUrl(),
                        t.getT1().contains(p.getId())))
                .toList());
    }
}
