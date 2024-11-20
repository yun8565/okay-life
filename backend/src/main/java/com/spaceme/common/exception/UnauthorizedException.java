package com.spaceme.common.exception;

import org.springframework.http.HttpStatus;

public class UnauthorizedException extends Exception {

    public UnauthorizedException(String message) {
        super(message, HttpStatus.UNAUTHORIZED);
    }
}
