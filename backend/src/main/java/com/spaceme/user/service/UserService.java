package com.spaceme.user.service;

import com.spaceme.common.exception.NotFoundException;
import com.spaceme.notification.service.FCMService;
import com.spaceme.user.domain.User;
import com.spaceme.user.dto.request.AlienConceptRequest;
import com.spaceme.user.dto.request.SpaceGoalRequest;
import com.spaceme.user.dto.response.UserResponse;
import com.spaceme.user.repository.UserRepository;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final FCMService fcmService;

    public void registerSpaceGoal(Long userId, SpaceGoalRequest request) {
        User user = findUser(userId);

        user.setSpaceGoal(request.spaceGoal());
    }

    @Transactional(readOnly = true)
    public UserResponse getCurrentUserInfo(Long userId) {
        User user = findUser(userId);

        return UserResponse.from(user);
    }

    public void updateDeviceToken(Long userId, String deviceToken) {
        User user = findUser(userId);

        user.updateDeviceToken(deviceToken);
    }

    public void updateAlienConcept(Long userId, String deviceToken, AlienConceptRequest request) {
        User user = findUser(userId);

        user.updateAlienConcept(request.alienConcept());
        fcmService.unSubscribeTopic(user.getAlienConcept(), deviceToken);
        fcmService.subscribeTopic(request.alienConcept(), deviceToken);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자 정보를 찾을 수 없습니다."));
    }
}
