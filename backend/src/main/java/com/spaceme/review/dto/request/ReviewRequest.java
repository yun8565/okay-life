package com.spaceme.review.dto.request;

public record ReviewRequest(
        Long planetId,
        String keep,
        String problem,
        String tryNext
) {
}
