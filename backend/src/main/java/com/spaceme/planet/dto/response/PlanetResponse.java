package com.spaceme.planet.dto.response;

import com.spaceme.common.Status;
import com.spaceme.mission.dto.response.MissionResponse;
import com.spaceme.planet.domain.Planet;

import java.util.List;

public record PlanetResponse(
        Long planetId,
        String title,
        Status status,
        Long planetThemeId,
        List<MissionResponse> missions
) {
    public static PlanetResponse of(Planet planet, List<MissionResponse> missions) {
        return new PlanetResponse(
                planet.getId(),
                planet.getTitle(),
                planet.getStatus(),
                planet.getPlanetTheme().getId(),
                missions
        );
    }
}
