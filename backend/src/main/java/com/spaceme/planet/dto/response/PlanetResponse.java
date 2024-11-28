package com.spaceme.planet.dto.response;

import com.spaceme.common.Status;
import com.spaceme.mission.dto.response.MissionResponse;
import com.spaceme.planet.domain.Planet;

import java.time.LocalDate;
import java.util.List;

public record PlanetResponse(
        Long planetId,
        String title,
        Status status,
        String planetThemeName,
        LocalDate startDate,
        LocalDate endDate,
        List<MissionResponse> missions
) {
    public static PlanetResponse of(Planet planet,
                                    List<MissionResponse> missions,
                                    LocalDate startDate,
                                    LocalDate endDate
    ) {
        return new PlanetResponse(
                planet.getId(),
                planet.getTitle(),
                planet.getStatus(),
                planet.getPlanetTheme().getName(),
                startDate,
                endDate,
                missions
        );
    }
}
