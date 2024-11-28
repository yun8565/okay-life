package com.spaceme.notification.service;

import com.spaceme.common.AlienConcept;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.notification.domain.Notification;
import com.spaceme.notification.repository.NotificationRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor(access = AccessLevel.PROTECTED)
@Transactional(readOnly = true)
public class NotificationService {

    private final NotificationRepository notificationRepository;

    private String pickRandomMessage(AlienConcept concept) {
        Notification notification = notificationRepository.findRandomMessageByConcept(concept)
                .orElseThrow(() -> new NotFoundException("해당하는 컨셉의 메시지를 찾을 수 없습니다."));

        notification.addSentCount();

        return notification.getMessage();
    }
}
