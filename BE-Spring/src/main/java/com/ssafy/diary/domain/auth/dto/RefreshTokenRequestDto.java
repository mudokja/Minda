package com.ssafy.diary.domain.auth.dto;

import lombok.Getter;
import lombok.ToString;

@Getter
@ToString
public class RefreshTokenRequestDto {
    private String refreshToken;
}
