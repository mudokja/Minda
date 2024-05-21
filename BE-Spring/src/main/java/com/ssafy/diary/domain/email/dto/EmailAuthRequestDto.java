package com.ssafy.diary.domain.email.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
public class EmailAuthRequestDto {
    private String verificationId;
    private String code;
    @Builder
    public EmailAuthRequestDto(String verificationId, String code) {
        this.verificationId = verificationId;
        this.code = code;
    }
}
