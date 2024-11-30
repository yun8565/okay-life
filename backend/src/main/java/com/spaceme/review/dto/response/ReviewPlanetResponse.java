package com.spaceme.review.dto.response;


public record ReviewPlanetResponse(
        String title,
        Long planetId,
        Long planetThemeId
) {
}
