package com.ssafy.diary.global.constant;

import lombok.Getter;

@Getter
public enum AuthType {
    GUEST(0),LOCAL(1),KAKAO(2),NAVER(3);
    private final int authTypeNumber;

    private AuthType(int authTypeNumber){
        this.authTypeNumber = authTypeNumber;
    }

}
