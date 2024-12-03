package com.spaceme.collection.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ThemeStatus {
    ACQUIRED(2),
    DISCOVERED(1),
    HIDDEN(0);

    private final int priority;

    public static ThemeStatus getHigherPriority(ThemeStatus status1, ThemeStatus status2) {
        return status1.priority >= status2.priority ? status1 : status2;
    }
}
