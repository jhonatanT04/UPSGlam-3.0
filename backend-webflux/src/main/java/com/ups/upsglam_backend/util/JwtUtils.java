package com.ups.upsglam_backend.util;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.UUID;

public class JwtUtils {

    private JwtUtils() {}

    /** Extrae el user UUID del campo "sub" del payload JWT sin validar firma. */
    public static UUID extractUserId(String bearerHeader) {
        try {
            String token   = extractToken(bearerHeader);
            if (token == null) return null;
            String payload = token.split("\\.")[1];
            String json    = new String(
                    Base64.getUrlDecoder().decode(payload), StandardCharsets.UTF_8);
            // Busca "sub":"<uuid>"
            int idx = json.indexOf("\"sub\":\"");
            if (idx == -1) return null;
            int start = idx + 7;
            int end   = json.indexOf("\"", start);
            return UUID.fromString(json.substring(start, end));
        } catch (Exception e) {
            return null;
        }
    }

    /** Devuelve solo el token sin el prefijo "Bearer ". */
    public static String extractToken(String bearerHeader) {
        if (bearerHeader == null) return null;
        return bearerHeader.startsWith("Bearer ")
                ? bearerHeader.substring(7)
                : bearerHeader;
    }
}
