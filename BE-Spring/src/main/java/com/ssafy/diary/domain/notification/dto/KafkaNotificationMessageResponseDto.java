package com.ssafy.diary.domain.notification.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
public class KafkaNotificationMessageResponseDto {
    private String resultMessage;
    @Builder
    public KafkaNotificationMessageResponseDto(String resultMessage) {
        this.resultMessage = resultMessage;
    }
}
