package com.spaceme.user.service;

import com.spaceme.common.exception.NotFoundException;
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

    public void registerSpaceGoal(Long userId, SpaceGoalRequest request) {
        UserPreference userPreference = findUserPreference(userId);

        userPreference.updateSpaceGoal(request.spaceGoal());
    }

    @Transactional(readOnly = true)
    public UserResponse getCurrentUserInfo(Long userId) {
        User user = findUser(userId);
        UserPreference userPreference = findUserPreference(userId);

        return UserResponse.from(user, userPreference);
    }

    public void updateUserPreference(Long userId, PreferenceRequest request) {
        UserPreference userPreference = findUserPreference(userId);

        request.spaceGoal().ifPresent(userPreference::updateSpaceGoal);
        request.alienConcept().ifPresent(userPreference::updateAlienConcept);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자 정보를 찾을 수 없습니다."));
    }

    private UserPreference findUserPreference(Long userId) {
        return userPreferenceRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자 설정 정보를 찾을 수 없습니다."));
    }
}
