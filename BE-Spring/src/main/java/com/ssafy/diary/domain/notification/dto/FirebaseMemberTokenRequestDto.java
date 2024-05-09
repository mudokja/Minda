package com.ssafy.diary.domain.notification.dto;

import com.ssafy.diary.global.constant.FireBasePlatform;
import lombok.Builder;
import lombok.Getter;

@Getter
public class FirebaseMemberTokenRequestDto {
    FireBasePlatform platform;
    String token;
    @Builder
    public FirebaseMemberTokenRequestDto(FireBasePlatform platform, String token) {
        this.platform = platform;
        this.token = token;
    }
}
