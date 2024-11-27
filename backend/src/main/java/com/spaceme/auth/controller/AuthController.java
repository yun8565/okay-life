package com.spaceme.auth.controller;

import com.spaceme.auth.dto.request.LoginRequest;
import com.spaceme.auth.dto.response.AccessTokenResponse;
import com.spaceme.auth.service.AuthService;
import com.spaceme.notification.domain.Device;
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
            @RequestBody LoginRequest loginRequest,
            @Device String deviceToken
    ) {
        AccessTokenResponse token = authService.login(provider, loginRequest, deviceToken);
        return ResponseEntity.ok(token);
    }
}
