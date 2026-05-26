package com.example.backend_webflux;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        boolean created = authService.register(request.getUsername(), request.getPassword());
        if (!created) {
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(new AuthResponse("El usuario ya existe"));
        }
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(new AuthResponse("Registro exitoso"));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        boolean authenticated = authService.login(request.getUsername(), request.getPassword());
        if (!authenticated) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(new AuthResponse("Usuario o contraseña incorrectos"));
        }
        return ResponseEntity.ok(new AuthResponse("Login exitoso"));
    }
}
