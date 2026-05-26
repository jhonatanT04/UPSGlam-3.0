package com.ups.upsglam_backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.UUID;

@Data
public class AuthResponse {

    @JsonProperty("access_token")
    private String accessToken;

    @JsonProperty("token_type")
    private String tokenType;

    @JsonProperty("expires_in")
    private Long expiresIn;

    @JsonProperty("refresh_token")
    private String refreshToken;

    private UserInfo user;

    @Data
    public static class UserInfo {
        private UUID id;
        private String email;

        @JsonProperty("user_metadata")
        private UserMetadata userMetadata;
    }

    @Data
    public static class UserMetadata {
        private String username;
    }
}
