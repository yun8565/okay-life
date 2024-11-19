package com.spaceme.mission.dto.response;

import com.spaceme.mission.domain.Status;

import java.util.Date;

public record MissionResponse(
        Long missionId,
        String content,
        Date date,
        Status status
) {
}