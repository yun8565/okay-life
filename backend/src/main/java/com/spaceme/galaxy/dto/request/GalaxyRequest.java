package com.spaceme.galaxy.dto.request;

import java.time.LocalDate;

public record GalaxyRequest(
        String title,
        LocalDate startDate,
        LocalDate endDate,
        int step
) {
}
