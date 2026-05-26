package com.example.backend_webflux;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final Map<String, String> users = new ConcurrentHashMap<>();

    public boolean register(String username, String password) {
        if (username == null || password == null || username.isBlank() || password.isBlank()) {
            return false;
        }
        return users.putIfAbsent(username, password) == null;
    }

    public boolean login(String username, String password) {
        if (username == null || password == null) {
            return false;
        }
        String storedPassword = users.get(username);
        return storedPassword != null && storedPassword.equals(password);
    }
}
