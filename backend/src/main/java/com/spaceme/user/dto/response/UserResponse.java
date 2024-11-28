package com.spaceme.user.dto.response;

import com.spaceme.common.AlienConcept;
import com.spaceme.user.domain.User;
import com.spaceme.user.domain.UserPreference;

public record UserResponse(
        String nickname,
        String spaceGoal,
        String email,
        AlienConcept concept
) {
    public static UserResponse from(User user, UserPreference preference) {
        return new UserResponse(
                user.getNickname(),
                preference.getSpaceGoal(),
                user.getEmail(),
                preference.getAlienConcept()
        );
    }
}
