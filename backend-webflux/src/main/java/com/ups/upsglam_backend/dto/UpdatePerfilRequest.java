package com.ups.upsglam_backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class UpdatePerfilRequest {
    private String username;

    @JsonProperty("avatar_url")
    private String avatarUrl;
}
