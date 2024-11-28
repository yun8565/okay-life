package com.spaceme.notification.controller;

import com.spaceme.auth.domain.Auth;
import com.spaceme.notification.dto.NotificationResponse;
import com.spaceme.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<NotificationResponse> pickNotificationMessage(@Auth Long userId) {
        return ResponseEntity.ok(notificationService.getTodayMessage(userId));
    }
}
