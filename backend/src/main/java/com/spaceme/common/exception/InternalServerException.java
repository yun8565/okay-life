package com.spaceme.common.exception;

import org.springframework.http.HttpStatus;

public class InternalServerException extends Exception {

    public InternalServerException(String message) {
        super(message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}