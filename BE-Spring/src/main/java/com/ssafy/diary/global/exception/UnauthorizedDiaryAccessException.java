package com.ssafy.diary.global.exception;

public class UnauthorizedDiaryAccessException extends RuntimeException {

    public UnauthorizedDiaryAccessException(String message) {
        super(message);
    }

    public UnauthorizedDiaryAccessException(String message, Throwable cause) {
        super(message, cause);
    }
}

