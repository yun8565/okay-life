package com.spaceme.common.exception;

import org.springframework.http.HttpStatus;

public class ForbiddenException extends Exception {

    public ForbiddenException(String message) {
        super(message, HttpStatus.FORBIDDEN);
    }
}
