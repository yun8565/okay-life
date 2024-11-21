package com.spaceme.user.controller;

import com.spaceme.auth.domain.Auth;
import com.spaceme.user.dto.SpaceGoalRequest;
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
}
