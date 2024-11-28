package com.spaceme.notification.controller;

import com.spaceme.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/notification/")
public class NotificationController {
    private final NotificationService notificationService;

}
