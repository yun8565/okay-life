package com.spaceme.notification.service;

import com.spaceme.common.AlienConcept;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.notification.domain.Notification;
import com.spaceme.notification.repository.NotificationRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;

@Service
@RequiredArgsConstructor(access = AccessLevel.PROTECTED)
@Transactional
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final FCMService fcmService;

    @Scheduled(cron = "0 0 9 * * ?")
    public void sendNotificationDaily() {
        Arrays.stream(AlienConcept.values()).forEach(concept -> {
            String message = pickRandomMessage(concept);
            fcmService.sendPushNotification(concept, message);
        });
    }

    private String pickRandomMessage(AlienConcept topic) {
        Notification notification = notificationRepository.findRandomMessageByConcept(topic)
                .orElseThrow(() -> new NotFoundException("해당하는 컨셉의 메시지를 찾을 수 없습니다."));

        notification.addSentCount();

        return notification.getMessage();
    }
}
