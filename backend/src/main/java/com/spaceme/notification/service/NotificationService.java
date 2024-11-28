package com.spaceme.notification.service;

import com.spaceme.common.AlienConcept;
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
import java.util.stream.IntStream;

import static java.nio.charset.StandardCharsets.UTF_8;

@Service
@RequiredArgsConstructor(access = AccessLevel.PROTECTED)
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserPreferenceRepository preferenceRepository;

    @Transactional
    public NotificationResponse getTodayMessage(Long userId) {
        LocalDate today = LocalDate.now();

        AlienConcept concept = preferenceRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자 설정 정보를 찾을 수 없습니다."))
                .getAlienConcept();

        List<Notification> notifications = notificationRepository.findAllByAlienConcept(concept);

        int index = calculateHashWithSent(today.toString(), notifications);
        Notification selected = notifications.get(index);
        selected.addSentCount();

        log.info("오늘의 메시지 (Concept: {}): {}", concept, selected.getMessage());
        return NotificationResponse.of(selected.getMessage());
    }

    private int calculateHashWithSent(String seed, List<Notification> notifications) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");

            byte[] combinedHash = digest.digest(
                    notifications.stream()
                            .map(notification -> seed + notification.getId() + notification.getSent())
                            .reduce("", (a, b) -> a + b)
                            .getBytes(UTF_8)
            );

            return Math.abs(combinedHashToStream(combinedHash)
                    .reduce(0, (result, b) -> (result * 31 + b) % notifications.size())
            );

        } catch (NoSuchAlgorithmException e) {
            throw new InternalServerException("해싱 알고리즘을 찾을 수 없습니다.");
        }
    }

    private IntStream combinedHashToStream(byte[] combinedHash) {
        return IntStream.range(0, combinedHash.length)
                .map(i -> combinedHash[i]);
    }
}
