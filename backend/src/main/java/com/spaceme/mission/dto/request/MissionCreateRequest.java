package com.spaceme.mission.dto.request;

import java.util.Date;

public record MissionCreateRequest(
        Long planetId,
        String content,
        Date date
) {
}
