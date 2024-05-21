package com.ssafy.diary.global.exception;

import com.amazonaws.services.kms.model.NotFoundException;
import com.google.firebase.messaging.FirebaseMessagingException;
import io.jsonwebtoken.ExpiredJwtException;
import lombok.extern.slf4j.Slf4j;
import org.apache.coyote.BadRequestException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.sql.SQLException;

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

    @ExceptionHandler(AlreadyExistsDiaryException.class)
    public ResponseEntity<String> handleAlreadyExistsDiaryException(AlreadyExistsDiaryException exception){
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
    @ExceptionHandler(UnauthorizedDiaryAccessException.class)
    public ResponseEntity<String> handleUnauthorizedDiaryAccessException(UnauthorizedDiaryAccessException exception){
        log.error("{} : UnauthorizedDiaryAccessException");
        return ResponseEntity
                .status(HttpStatus.FORBIDDEN)
                .body(exception.getMessage());
    }
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<String> handleRuntimeException(RuntimeException exception) {
        log.error("Runtime exception: ", exception);
        String message="Request Failed";
        if(exception.getCause()==null){
        message = exception.getMessage();
        }

        return ResponseEntity.badRequest().body(message);
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
    public ResponseEntity<String> handleBadRequestException(Exception exception) {
        log.error("BadRequestException: ", exception);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception.getMessage());
    }
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<String> handleBadRequestException(RuntimeException exception) {
        log.error("BadCredentialsException: ", exception);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception.getMessage());
    }
    @ExceptionHandler(EmailException.class)
    public ResponseEntity<String> handleEmailException(RuntimeException exception) {
        log.error("EmailException: ", exception);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception.getMessage());
    }
    @ExceptionHandler(NotificationException.NotificationTokenDuplicatedException.class)
    public ResponseEntity<String> handleNotificationTokenDuplicatedException(RuntimeException exception) {
        log.error("NotificationTokenDuplicatedException: ", exception);
        return ResponseEntity.status(HttpStatus.CONFLICT).body(exception.getMessage());
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
    @ExceptionHandler(ExpiredJwtException.class)
    public ResponseEntity<String> handleExpiredJwtException(ExpiredJwtException exception) {
        log.error("JWT token is expired: ", exception);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token is expired");
    }
    @ExceptionHandler(SQLException.class)
    public ResponseEntity<String> handleSQLException(RuntimeException exception) {
        log.error("SQLException: ", exception);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Internal Server Error");
    }
    @ExceptionHandler(AlreadyExistsEmailException.class)
    public ResponseEntity<String> handleAlreadyExistsEmailException(RuntimeException exception){
        log.error("{} : AlreadyExistsEmailException", exception.getMessage());
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(exception.getMessage());
    }
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<String> handleIllegalArgumentExceptionException(RuntimeException exception){
        log.error("{} : IllegalArgumentExceptionException", exception.getMessage());
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST )
                .body(exception.getMessage());
    }
    @ExceptionHandler(MemberRegisterException.class)
    public ResponseEntity<String> handleMemberRegisterException(RuntimeException exception) {
        log.error("MemberRegisterException: ", exception);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(exception.getMessage());
    }
}
