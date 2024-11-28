package com.spaceme.notification.service;

import com.spaceme.common.AlienConcept;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.notification.domain.Notification;
import com.spaceme.notification.repository.NotificationRepository;
import com.spaceme.user.domain.NotificationPreference;
import com.spaceme.user.service.UserService;
import jakarta.annotation.PostConstruct;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.*;
import java.util.Arrays;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;

import static java.util.concurrent.TimeUnit.HOURS;
import static java.util.concurrent.TimeUnit.SECONDS;

@Service
@RequiredArgsConstructor(access = AccessLevel.PROTECTED)
@Transactional(readOnly = true)
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(10);
    private final FCMService fcmService;
    private final UserService userService;

    @PostConstruct
    public void initializeRepeatingNotifications() {
        Arrays.stream(NotificationPreference.values())
                .filter(preference -> preference != NotificationPreference.OFF)
                .forEach(preference ->
                        Arrays.stream(AlienConcept.values()).forEach(concept -> {
                            if (hasSubscribers(preference, concept))
                                scheduleRepeatingNotification(preference, concept);
                        })
                );
    }

    public void scheduleRepeatingNotification(NotificationPreference preference, AlienConcept concept) {
        long initialDelay = calculateDelayInSeconds(calculateNextExecutionTime(preference.getHour()));
        long periodInSeconds = HOURS.toSeconds(24);

        String topic = generateTopic(preference, concept);
        String message = pickRandomMessage(concept);

        scheduler.scheduleAtFixedRate(() ->
                sendNotification(topic, message), initialDelay, periodInSeconds, SECONDS
        );
    }

    private LocalDateTime calculateNextExecutionTime(int hour) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime nextExecutionTime = now.withHour(hour).withMinute(0).withSecond(0);

        if (nextExecutionTime.isBefore(now))
            nextExecutionTime = nextExecutionTime.plusDays(1);

        return nextExecutionTime;
    }

    private long calculateDelayInSeconds(LocalDateTime nextExecutionTime) {
        return nextExecutionTime.atZone(ZoneId.systemDefault()).toEpochSecond()
                - LocalDateTime.now().atZone(ZoneId.systemDefault()).toEpochSecond();
    }

    public void sendNotification(String topic, String message) {
        fcmService.sendPushNotification(topic, message);
    }

    private String pickRandomMessage(AlienConcept concept) {
        Notification notification = notificationRepository.findRandomMessageByConcept(concept)
                .orElseThrow(() -> new NotFoundException("해당하는 컨셉의 메시지를 찾을 수 없습니다."));

        notification.addSentCount();

        return notification.getMessage();
    }

    private boolean hasSubscribers(NotificationPreference preference, AlienConcept concept) {
        return userService.hasSubscribers(preference, concept);
    }

    private String generateTopic(NotificationPreference preference, AlienConcept concept) {
        return String.join("_",preference.name(), concept.name());
    }
}
