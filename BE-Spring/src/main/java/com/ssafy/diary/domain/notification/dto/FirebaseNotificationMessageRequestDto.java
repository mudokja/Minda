package com.ssafy.diary.domain.notification.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
public class FirebaseNotificationMessageRequestDto {
    private Long memberIndex;
    private String title;
    private String body;
    @Builder
    public FirebaseNotificationMessageRequestDto(Long memberIndex, String title, String body) {
        this.memberIndex = memberIndex;
        this.title = title;
        this.body = body;
    }
}
