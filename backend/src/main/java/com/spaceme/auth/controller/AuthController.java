package com.spaceme.auth.controller;

import com.spaceme.auth.dto.request.LoginRequest;
import com.spaceme.auth.dto.response.AccessTokenResponse;
import com.spaceme.auth.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login/{provider}")
    public ResponseEntity<AccessTokenResponse> login(
            @PathVariable String provider,
            @RequestBody LoginRequest loginRequest
    ) {
        AccessTokenResponse token = authService.login(provider, loginRequest);
        return ResponseEntity.ok(token);
    }
}
