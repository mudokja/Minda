package com.ssafy.diary.domain.member.dto;

import com.ssafy.diary.global.constant.AuthType;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Getter
@ToString
public class MemberOauth2RegisterRequestDto {
    private AuthType platform;
    private String id;
    private String nickname;
    private String email;
    @Builder
    public MemberOauth2RegisterRequestDto(AuthType platform, String id, String nickname, String email) {
        this.platform = platform;
        this.id = id;
        this.nickname = nickname;
        this.email = email;
    }
}
