package com.spaceme.chatGPT.dto;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

public record PlanRequest(
        String title,
        LocalDate startDate,
        LocalDate endDate,
        int step
) {
}