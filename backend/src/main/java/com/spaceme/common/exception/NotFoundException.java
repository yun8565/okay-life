package com.spaceme.common.exception;

import org.springframework.http.HttpStatus;

public class NotFoundException extends Exception {

    public NotFoundException(String message) {
        super(message, HttpStatus.NOT_FOUND);
    }
}
