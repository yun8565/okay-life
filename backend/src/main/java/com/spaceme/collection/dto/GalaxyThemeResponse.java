package com.spaceme.collection.dto;

import com.spaceme.collection.domain.GalaxyTheme;

import java.util.List;

public record GalaxyThemeResponse(
        Long galaxyThemeId,
        String name,
        List<PlanetThemeResponse> planetThemeList
) {
    public static GalaxyThemeResponse of(GalaxyTheme galaxyTheme, List<PlanetThemeResponse> planetThemeList) {
        return new GalaxyThemeResponse(
                galaxyTheme.getId(),
                galaxyTheme.getName(),
                planetThemeList
        );
    }
}