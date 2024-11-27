package com.spaceme.user.controller;

import com.spaceme.auth.domain.Auth;
import com.spaceme.notification.domain.Device;
import com.spaceme.user.dto.request.AlienConceptRequest;
import com.spaceme.user.dto.request.SpaceGoalRequest;
import com.spaceme.user.dto.response.UserResponse;
import com.spaceme.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    @PostMapping("/goal")
    public ResponseEntity<Void> registerSpaceGoal(
            @RequestBody SpaceGoalRequest request,
            @Auth Long userId
    ) {
        userService.registerSpaceGoal(userId, request);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUserInfo(@Auth Long userId) {
        return ResponseEntity.ok(userService.getCurrentUserInfo(userId));
    }

    @PutMapping("/token")
    public ResponseEntity<Void> updateDeviceToken(
            @Auth Long userId,
            @Device String deviceToken
    ) {
        userService.updateDeviceToken(userId, deviceToken);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/me")
    public ResponseEntity<Void> updateUserInfo(
            @Auth Long userId,
            @Device String deviceToken,
            @RequestBody AlienConceptRequest alienConceptRequest
    ) {
        userService.updateAlienConcept(userId, deviceToken, alienConceptRequest);
        return ResponseEntity.noContent().build();
    }
}
