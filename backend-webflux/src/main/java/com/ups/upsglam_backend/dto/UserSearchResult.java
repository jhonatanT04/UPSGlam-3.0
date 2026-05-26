package com.ups.upsglam_backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.UUID;

@Data
@AllArgsConstructor
public class UserSearchResult {
    private UUID id;
    private String username;

    @JsonProperty("avatar_url")
    private String avatarUrl;

    @JsonProperty("is_following")
    private boolean isFollowing;
}
