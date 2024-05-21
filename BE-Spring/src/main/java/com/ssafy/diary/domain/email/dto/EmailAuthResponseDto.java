package com.ssafy.diary.domain.email.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class EmailAuthResponseDto {
    private String resultMessage;
    private String email;
    LocalDateTime authTime;
    @Builder
    public EmailAuthResponseDto(String email, LocalDateTime authTime, String resultMessage) {
        this.email = email;
        this.authTime = authTime;
        this.resultMessage = resultMessage;
    }
}
