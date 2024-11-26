package com.spaceme.planet.dto.response;

public record RatioResponse(
        boolean acquired,
        int clearRatio
) {
    public static RatioResponse of(boolean acquired, int clearRatio) {
        return new RatioResponse(acquired, clearRatio);
    }
}
