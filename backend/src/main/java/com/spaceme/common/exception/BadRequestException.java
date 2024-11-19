package com.spaceme.common.exception;

import org.springframework.http.HttpStatus;

public class BadRequestException extends Exception {

    public BadRequestException(String message) {
        super(message, HttpStatus.BAD_REQUEST);
    }
}
