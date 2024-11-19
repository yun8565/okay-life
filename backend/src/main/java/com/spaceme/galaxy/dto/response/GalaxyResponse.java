package com.spaceme.galaxy.dto.response;

import com.spaceme.galaxy.domain.Galaxy;
import com.spaceme.planet.dto.response.PlanetResponse;

import java.time.LocalDate;
import java.util.List;

public record GalaxyResponse(
        String title,
        Long planetThemeIdRepresenting,
        List<PlanetResponse> planets,
        LocalDate endDate
) {
    public static GalaxyResponse of(Galaxy galaxy, List<PlanetResponse> planets) {
        return new GalaxyResponse(
                galaxy.getTitle(),
                galaxy.getId(),
                planets,
                galaxy.getEndDate()
        );
    }
}
