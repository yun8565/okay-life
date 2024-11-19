package com.spaceme.mission.dto.request;

import java.time.LocalDate;

public record MissionCreateRequest(
        Long planetId,
        String content,
        LocalDate date
) {
}
