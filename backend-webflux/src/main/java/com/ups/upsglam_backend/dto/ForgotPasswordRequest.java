package com.ups.upsglam_backend.dto;

import lombok.Data;

@Data
public class ForgotPasswordRequest {
    private String identifier; // email o username
}
