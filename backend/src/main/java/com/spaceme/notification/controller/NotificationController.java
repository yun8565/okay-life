package com.spaceme.notification.controller;

import com.spaceme.notification.dto.NotificationTestRequest;
import com.spaceme.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping
    public ResponseEntity<Void> test(@RequestBody NotificationTestRequest request) {
        notificationService.sendNotification(request.topic(), request.message());
        return ResponseEntity.noContent().build();
    }
}
