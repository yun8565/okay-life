package com.spaceme.galaxy.dto.response;

import com.spaceme.galaxy.domain.Galaxy;
import com.spaceme.planet.dto.response.PlanetResponse;

import java.time.LocalDate;
import java.util.List;

public record GalaxyResponse(
        Long galaxyId,
        String title,
        String planetThemeNameRepresenting,
        List<PlanetResponse> planets,
        LocalDate startDate,
        LocalDate endDate
) {
    public static GalaxyResponse of(Galaxy galaxy, List<PlanetResponse> planets) {
        return new GalaxyResponse(
                galaxy.getId(),
                galaxy.getTitle(),
                planets.get(0).planetThemeName(),
                planets,
                galaxy.getStartDate(),
                galaxy.getEndDate()
        );
    }
}