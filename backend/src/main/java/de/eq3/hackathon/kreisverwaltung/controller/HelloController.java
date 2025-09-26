package de.eq3.hackathon.kreisverwaltung.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HelloController {

    @GetMapping("/hello")
    public ResponseEntity<Map<String, Object>> hello() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Hello World from Datenraum Ostfriesland!");
        response.put("timestamp", LocalDateTime.now());
        response.put("authenticated", authentication != null && authentication.isAuthenticated()
                && !authentication.getName().equals("anonymousUser"));

        if (authentication != null && authentication.isAuthenticated()
                && !authentication.getName().equals("anonymousUser")) {
            response.put("username", authentication.getName());
            response.put("authorities", authentication.getAuthorities());
        }

        return ResponseEntity.ok(response);
    }

    @GetMapping("/public/hello")
    public ResponseEntity<Map<String, String>> publicHello() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Hello World from Datenraum Ostfriesland - Public Endpoint!");
        response.put("info", "This endpoint does not require authentication");
        response.put("timestamp", LocalDateTime.now().toString());

        return ResponseEntity.ok(response);
    }
}