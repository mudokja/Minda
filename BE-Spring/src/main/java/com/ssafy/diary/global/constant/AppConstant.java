package com.ssafy.diary.global.constant;

import lombok.Getter;
import org.checkerframework.checker.units.qual.N;
import org.springframework.http.HttpStatus;
import org.springframework.lang.Nullable;


public enum AppConstant {
    APP_NAME("ColDiary"),
    NOTIFICATION_MEMBER_TOPIC("diary.notification.member"),
    NOTIFICATION_TOKEN_TOPIC("diary.notification.token"),
    EMAIL_VERIFICATION_TOPIC("diary.email.verification");
    private final String value;
    private final static AppConstant[] VALUES;
    static{
        VALUES=values();
    }

    public static String valueOf(AppConstant appConstant) {
        for (AppConstant constant : VALUES) {
            if(constant.value.equals(appConstant.value))
                return constant.value;
        }
        return "";
    }
    AppConstant(String value) {
        this.value = value;
    }
    public String value(){
        return value;
    }

}
