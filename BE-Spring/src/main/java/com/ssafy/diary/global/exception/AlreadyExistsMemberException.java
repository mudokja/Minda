package com.ssafy.diary.global.exception;

public class AlreadyExistsMemberException extends RuntimeException{
    public AlreadyExistsMemberException(String message) {
        super(message);
    }
}
