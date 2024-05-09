package com.ssafy.diary.domain.notification.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class KafkaNotificationMessageResponseDto {
    private String resultMessage;
    @Builder
    public KafkaNotificationMessageResponseDto(String resultMessage) {
        this.resultMessage = resultMessage;
    }
}
