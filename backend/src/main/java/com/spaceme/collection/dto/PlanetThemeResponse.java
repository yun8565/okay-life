package com.spaceme.collection.dto;

import com.spaceme.collection.domain.PlanetTheme;
import com.spaceme.collection.domain.ThemeStatus;

public record PlanetThemeResponse(
        Long planetThemeId,
        String name,
        ThemeStatus status
) {
    public static PlanetThemeResponse of(PlanetTheme planetTheme, ThemeStatus status) {
        return new PlanetThemeResponse(
                planetTheme.getId(),
                planetTheme.getName(),
                status
        );
    }
}
