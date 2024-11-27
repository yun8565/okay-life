package com.spaceme.notification.controller;

import com.spaceme.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<Void> test() {
        notificationService.sendNotificationDaily();
        return ResponseEntity.noContent().build();
    }
}
