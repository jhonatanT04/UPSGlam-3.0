package com.ups.upsglam_backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
@Builder
public class PerfilResponse {

    private UUID id;
    private String username;

    @JsonProperty("avatar_url")
    private String avatarUrl;

    @JsonProperty("publicaciones_count")
    private int publicacionesCount;

    @JsonProperty("total_likes")
    private long totalLikes;

    private List<PublicacionResponse> publicaciones;
}
