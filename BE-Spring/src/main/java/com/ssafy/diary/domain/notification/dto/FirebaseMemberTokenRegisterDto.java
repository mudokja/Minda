package com.ssafy.diary.domain.notification.dto;

import com.ssafy.diary.global.constant.FireBasePlatform;
import lombok.Builder;
import lombok.Getter;

@Getter
public class FirebaseMemberTokenRegisterDto {
    FireBasePlatform platform;
    String token;
    @Builder
    public FirebaseMemberTokenRegisterDto(FireBasePlatform platform, String token) {
        this.platform = platform;
        this.token = token;
    }
}
