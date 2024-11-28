package com.spaceme.user.service;

import com.spaceme.common.AlienConcept;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.notification.service.FCMService;
import com.spaceme.user.domain.NotificationPreference;
import com.spaceme.user.domain.User;
import com.spaceme.user.domain.UserPreference;
import com.spaceme.user.dto.request.PreferenceRequest;
import com.spaceme.user.dto.request.SpaceGoalRequest;
import com.spaceme.user.dto.response.UserResponse;
import com.spaceme.user.repository.UserPreferenceRepository;
import com.spaceme.user.repository.UserRepository;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final UserPreferenceRepository userPreferenceRepository;
    private final FCMService fcmService;

    public void registerSpaceGoal(Long userId, SpaceGoalRequest request) {
        UserPreference userPreference = findUserPreference(userId);

        userPreference.setSpaceGoal(request.spaceGoal());
    }

    @Transactional(readOnly = true)
    public UserResponse getCurrentUserInfo(Long userId) {
        User user = findUser(userId);
        UserPreference userPreference = findUserPreference(userId);

        return UserResponse.from(user, userPreference.getSpaceGoal());
    }

    public void updateDeviceToken(Long userId, String deviceToken) {
        User user = findUser(userId);

        user.updateDeviceToken(deviceToken);
    }

    public void updateUserPreference(Long userId, String deviceToken, PreferenceRequest request) {
        UserPreference userPreference = findUserPreference(userId);

        request.spaceGoal().ifPresent(userPreference::setSpaceGoal);

        request.alienConcept().ifPresent(alienConcept -> {
            updateAlienConcept(userPreference, alienConcept, deviceToken);
        });

        request.notificationPreference().ifPresent(notificationPreference -> {
            updateNotificationPreference(userPreference, notificationPreference, deviceToken);
        });
    }

    private void updateNotificationPreference(UserPreference userPreference, NotificationPreference notificationPreference, String deviceToken) {
        fcmService.unSubscribeTopic(generateTopic(
                userPreference.getNotificationPreference(),
                userPreference.getAlienConcept()
        ), deviceToken);

        fcmService.subscribeTopic(generateTopic(
                notificationPreference,
                userPreference.getAlienConcept()
        ), deviceToken);
    }

    private void updateAlienConcept(UserPreference userPreference, AlienConcept alienConcept, String deviceToken) {
        fcmService.unSubscribeTopic(generateTopic(
                userPreference.getNotificationPreference(),
                userPreference.getAlienConcept()
        ), deviceToken);

        fcmService.subscribeTopic(generateTopic(
                userPreference.getNotificationPreference(),
                alienConcept
        ), deviceToken);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자 정보를 찾을 수 없습니다."));
    }

    private UserPreference findUserPreference(Long userId) {
        return userPreferenceRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자 설정 정보를 찾을 수 없습니다."));
    }

    private String generateTopic(NotificationPreference preference, AlienConcept concept) {
        return String.join("_",preference.name(), concept.name());
    }

    public boolean hasSubscribers(NotificationPreference preference, AlienConcept concept) {
        return userPreferenceRepository.existsByAlienConceptAndNotificationPreference(concept, preference);
    }
}
