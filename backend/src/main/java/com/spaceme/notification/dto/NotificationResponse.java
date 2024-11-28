package com.spaceme.notification.dto;

public record NotificationResponse(
        String message
) {
    public static NotificationResponse of(String message) {
        return new NotificationResponse(message);
    }
}
