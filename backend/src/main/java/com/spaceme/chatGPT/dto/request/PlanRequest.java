package com.spaceme.chatGPT.dto.request;

import java.util.List;

public record PlanRequest(
        String title,
        String startDate,
        String endDate,
        int step,
        List<String> days,
        List<AnswerRequest> answers
) {
}