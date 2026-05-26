package com.ups.upsglam_backend.controller;

import com.ups.upsglam_backend.dto.AuthResponse;
import com.ups.upsglam_backend.dto.ForgotPasswordRequest;
import com.ups.upsglam_backend.dto.LoginRequest;
import com.ups.upsglam_backend.dto.RegisterRequest;
import com.ups.upsglam_backend.service.AuthService;
import com.ups.upsglam_backend.util.JwtUtils;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/v1/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<AuthResponse> register(@RequestBody RegisterRequest req) {
        return authService.register(req);
    }

    @PostMapping("/login")
    public Mono<AuthResponse> login(@RequestBody LoginRequest req) {
        return authService.login(req);
    }

    @PostMapping("/forgot-password")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> forgotPassword(@RequestBody ForgotPasswordRequest req) {
        return authService.forgotPassword(req);
    }

    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> logout(@RequestHeader("Authorization") String bearer) {
        return authService.logout(JwtUtils.extractToken(bearer));
    }
}
