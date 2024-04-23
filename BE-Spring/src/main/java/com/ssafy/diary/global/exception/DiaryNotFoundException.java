package com.ssafy.diary.global.exception;

public class DiaryNotFoundException extends RuntimeException {

    public DiaryNotFoundException() {
        super();
    }

    public DiaryNotFoundException(String message) {
        super(message);
    }

    public DiaryNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }

    public DiaryNotFoundException(Throwable cause) {
        super(cause);
    }
}