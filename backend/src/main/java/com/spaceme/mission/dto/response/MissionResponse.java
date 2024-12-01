package com.spaceme.mission.dto.response;

import com.spaceme.common.domain.Status;
import com.spaceme.mission.domain.Mission;

import java.time.LocalDate;

public record MissionResponse(
        Long missionId,
        String content,
        LocalDate date,
        Status status
) {
    public static MissionResponse from(Mission mission) {
        return new MissionResponse(
                mission.getId(),
                mission.getContent(),
                mission.getDate(),
                mission.getStatus()
        );
    }
}