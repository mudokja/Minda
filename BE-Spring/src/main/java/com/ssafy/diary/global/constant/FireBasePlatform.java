package com.ssafy.diary.global.constant;

import lombok.Getter;

@Getter
public enum FireBasePlatform {
    ANDROID("android"),IOS("apns"),WEB("webpush"),UNKNOWN("unknown");

    private final String platformOptionName;
    FireBasePlatform(String platformOption) {
        this.platformOptionName = platformOption;
    }

}
