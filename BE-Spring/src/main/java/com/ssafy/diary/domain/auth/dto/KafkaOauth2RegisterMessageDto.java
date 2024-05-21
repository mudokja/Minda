package com.ssafy.diary.domain.auth.dto;

import com.ssafy.diary.global.constant.AuthType;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class KafkaOauth2RegisterMessageDto {
    private AuthType platform;
    private String id;
    private String nickname;
    private String email;
    @Builder
    public KafkaOauth2RegisterMessageDto(AuthType platform, String id, String nickname, String email) {
        this.platform = platform;
        this.id = id;
        this.nickname = nickname;
        this.email = email;
    }
}
