package com.spaceme.user.dto.response;

import com.spaceme.user.domain.User;

public record UserResponse(
        String nickname,
        String spaceGoal,
        String email
) {
    public static UserResponse from(User user, String spaceGoal) {
        return new UserResponse(
                user.getNickname(),
                spaceGoal,
                user.getEmail()
        );
    }
}
