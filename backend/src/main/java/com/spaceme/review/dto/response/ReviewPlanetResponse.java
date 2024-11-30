package com.spaceme.review.dto.response;


import com.spaceme.common.domain.Status;

public record ReviewPlanetResponse(
        String title,
        Long planetId,
        String planetThemeName,
        Status status
) {
}
