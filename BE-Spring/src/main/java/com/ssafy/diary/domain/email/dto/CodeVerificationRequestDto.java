package com.ssafy.diary.domain.email.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CodeVerificationRequestDto {
    private String email;
    @Builder
    public CodeVerificationRequestDto(String email) {
        this.email = email;
    }
}
