package com.spaceme.planet.dto;

public record PlanetResponseDTO(
        Long planetId,
        String title,
        Boolean achieved,
        Long galaxyId,
        Long planetThemeId
) {}
