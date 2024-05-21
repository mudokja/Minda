package com.ssafy.diary.global.exception;

public class EmailException extends RuntimeException {
    public EmailException(String message) {
        super(message);
    }
    public static class EmailNotValidEmail extends EmailException {
        public EmailNotValidEmail(String message) {
            super(message);
        }
    }
    public static class EmailVerificationRequestTooMany extends EmailException {
        public EmailVerificationRequestTooMany(String message) {
            super(message);
        }
    }
}
