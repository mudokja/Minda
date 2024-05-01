package com.ssafy.diary.domain.auth.dto;

import com.ssafy.diary.global.constant.AuthType;
import lombok.Builder;
import lombok.Getter;

@Getter
public class Oauth2LoginRequestDto {
    private AuthType platform;
    private String id;
    private String nickname;
    private String email;
    @Builder
    public Oauth2LoginRequestDto(AuthType platform, String id, String nickname, String email) {
        this.platform = platform;
        this.id = id;
        this.nickname = nickname;
        this.email = email;
    }
}
