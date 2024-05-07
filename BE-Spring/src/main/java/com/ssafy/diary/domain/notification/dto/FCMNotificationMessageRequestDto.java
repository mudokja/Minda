package com.ssafy.diary.domain.notification.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
public class FCMNotificationMessageRequestDto {
    private String targetToken;
    private String title;
    private String body;
    @Builder
    public FCMNotificationMessageRequestDto(String targetToken, String title, String body) {
        this.targetToken = targetToken;
        this.title = title;
        this.body = body;
    }
}
