package com.spaceme.chatGPT.dto.request;

import java.time.LocalDate;
import java.util.List;

public record PlanRequest(
        String title,
        LocalDate startDate,
        LocalDate endDate,
        int step,
        List<String> days,
        List<AnswerRequest> answers
) {
}