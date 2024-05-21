package com.ssafy.diary.domain.email.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
public class CodeVerificationResponseDto {
    private String verificationId;
    @Builder
    public CodeVerificationResponseDto(String verificationId) {
        this.verificationId = verificationId;
    }
}
