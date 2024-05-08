package com.ssafy.diary.domain.notification.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.experimental.SuperBuilder;
import org.springframework.lang.NonNull;

@Getter
@SuperBuilder
public class KafkaTokenNotificationMessageRequestDto extends KafkaNotificationMessageRequestDto {
    private String token;

//    @Builder
    public KafkaTokenNotificationMessageRequestDto(String token, String title, String body) {
        super(title, body);
        this.token = token;
    }

}
