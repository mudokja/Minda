package com.ssafy.diary.global.exception;

public class NotificationException extends RuntimeException{
    public NotificationException(String message) {
        super(message);
    }
    public static class NotificationTokenDuplicatedException extends NotificationException {
        public NotificationTokenDuplicatedException(String message) {
            super(message);
        }
    }
}
