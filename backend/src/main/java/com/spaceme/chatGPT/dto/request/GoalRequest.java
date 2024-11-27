package com.spaceme.chatGPT.dto.request;

public record GoalRequest(
        String goal,
        String startDate,
        String endDate
) {
}
