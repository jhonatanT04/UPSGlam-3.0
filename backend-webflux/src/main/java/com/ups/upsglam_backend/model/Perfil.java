package com.ups.upsglam_backend.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Perfil {

    private UUID id;
    private String username;

    @JsonProperty("avatar_url")
    private String avatarUrl;

    @JsonProperty("creado_en")
    private ZonedDateTime creadoEn;
}
