package com.spaceme.user.service;

import com.spaceme.common.exception.NotFoundException;
import com.spaceme.user.domain.User;
import com.spaceme.user.dto.SpaceGoalRequest;
import com.spaceme.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Transactional
public class UserService {

    private final UserRepository userRepository;

    public void registerSpaceGoal(Long userId, SpaceGoalRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자 정보를 찾을 수 없습니다."));

        user.setSpaceGoal(request.spaceGoal());
    }
}
