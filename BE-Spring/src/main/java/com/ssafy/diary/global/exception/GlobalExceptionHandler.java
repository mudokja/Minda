package com.ssafy.diary.global.exception;

import com.amazonaws.services.kms.model.NotFoundException;
import com.google.firebase.messaging.FirebaseMessagingException;
import io.jsonwebtoken.ExpiredJwtException;
import lombok.extern.slf4j.Slf4j;
import org.apache.coyote.BadRequestException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    @ExceptionHandler(AlreadyExistsMemberException.class)
    public ResponseEntity<String> handleAlreadyExistsMemberException(AlreadyExistsMemberException exception){
        log.error("{} : AlreadyExistsMember", exception.getMessage());
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(exception.getMessage());
    }
    @ExceptionHandler(DiaryNotFoundException.class)
    public ResponseEntity<String> handleDiaryNotFoundException(DiaryNotFoundException exception){
        log.error("{} : DiaryNotFoundException");
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(exception.getMessage());
    }
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<String> handleRuntimeException(RuntimeException exception) {
        log.error("Runtime exception: ", exception);
        return ResponseEntity.badRequest().body(exception.getMessage());
    }
    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleGeneralException(Exception exception) {
        log.error("General exception: ", exception);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Internal Server Error");
    }
    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<String> handleNotFoundException(RuntimeException exception) {
        log.error("NotFoundException: ", exception);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(exception.getMessage());
    }
    @ExceptionHandler(UsernameNotFoundException.class)
    public ResponseEntity<String> handleUsernameNotFoundException(RuntimeException exception) {
        log.error("UsernameNotFoundException: ", exception);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(exception.getMessage());
    }
    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<String> handleBadRequestException(RuntimeException exception) {
        log.error("BadRequestException: ", exception);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception.getMessage());
    }
    @ExceptionHandler(EmailException.class)
    public ResponseEntity<String> handleEmailException(RuntimeException exception) {
        log.error("EmailException: ", exception);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception.getMessage());
    }
    @ExceptionHandler(NotificationException.class)
    public ResponseEntity<String> handleNotificationException(RuntimeException exception) {
        log.error("NotificationException: ", exception);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception.getMessage());
    }
    @ExceptionHandler(FirebaseMessagingException.class)
    public ResponseEntity<String> handleFireBaseException(RuntimeException exception) {
        log.error("FireBaseException: ", exception);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("FireBase Error");
    }
}
