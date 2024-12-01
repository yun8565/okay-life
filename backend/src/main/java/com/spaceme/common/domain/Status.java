package com.spaceme.common.domain;

public enum Status {
    SOON, FAILED, CLEAR, ON_PROGRESS, ACQUIRABLE;

    public boolean isPast() {
        return this == FAILED || this == CLEAR;
    }
}