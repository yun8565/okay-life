package com.spaceme.review.dto.response;

public record ReviewResponse(
        String planetTitle,
        String keep,
        String problem,
        String tryNext
) {
}
