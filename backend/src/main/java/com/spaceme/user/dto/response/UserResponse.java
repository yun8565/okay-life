package com.spaceme.user.dto.response;

import com.spaceme.user.domain.User;

public record UserResponse(
        String nickname,
        String spaceGoal
) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getNickname(),
                user.getSpaceGoal()
        );
    }
}
