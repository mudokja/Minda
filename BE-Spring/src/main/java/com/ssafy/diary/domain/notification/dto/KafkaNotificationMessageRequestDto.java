package com.ssafy.diary.domain.notification.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@Getter
@SuperBuilder
@NoArgsConstructor
public class KafkaNotificationMessageRequestDto {
    protected String title;
    protected String body;
//    @Builder
    public KafkaNotificationMessageRequestDto(String title, String body) {
        this.title = title;
        this.body = body;
    }
}
