package com.spaceme.notification.service;

import com.spaceme.common.domain.AlienConcept;
import com.spaceme.common.exception.InternalServerException;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.notification.domain.Notification;
import com.spaceme.notification.dto.NotificationResponse;
import com.spaceme.notification.repository.NotificationRepository;
import com.spaceme.user.repository.UserPreferenceRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDate;
import java.util.List;

import static java.nio.charset.StandardCharsets.UTF_8;

@Service
@RequiredArgsConstructor(access = AccessLevel.PROTECTED)
@Slf4j
@Transactional
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserPreferenceRepository preferenceRepository;

    public NotificationResponse getTodayMessage(Long userId) {
        LocalDate today = LocalDate.now();

        AlienConcept concept = preferenceRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자 설정 정보를 찾을 수 없습니다."))
                .getAlienConcept();

        List<Notification> notifications = notificationRepository.findAllByAlienConcept(concept);

        int index = calculateHashWithSent(today.toString(), notifications);
        Notification selected = notifications.get(index);

        log.info("오늘의 메시지 (Concept: {}): {}", concept, selected.getMessage());
        return NotificationResponse.of(selected.getMessage());
    }

    private int calculateHashWithSent(String seed, List<Notification> notifications) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");

            byte[] combinedHash = digest.digest(
                    notifications.stream()
                            .map(notification -> seed + "-" + notification.getId()) // 날짜 + ID를 조합
                            .reduce("", String::concat)
                            .getBytes(UTF_8)
            );
            return Math.abs(toInt(combinedHash) % notifications.size());

        } catch (NoSuchAlgorithmException e) {
            throw new InternalServerException("해싱 알고리즘을 찾을 수 없습니다.");
        }
    }

    private int toInt(byte[] hash) {
        return ((hash[0] & 0xFF) << 24) | ((hash[1] & 0xFF) << 16) | ((hash[2] & 0xFF) << 8) | (hash[3] & 0xFF);
    }
}
