package com.ssafy.diary.global.exception;

public class AlreadyExistsDiaryException extends RuntimeException {
    public AlreadyExistsDiaryException(String message) {
        super(message);
    }
}
