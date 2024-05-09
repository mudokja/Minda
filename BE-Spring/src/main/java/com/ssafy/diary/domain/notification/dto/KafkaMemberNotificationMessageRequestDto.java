package com.ssafy.diary.domain.notification.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;
import org.springframework.lang.NonNull;

@Getter
@SuperBuilder
@NoArgsConstructor
public class KafkaMemberNotificationMessageRequestDto extends KafkaNotificationMessageRequestDto {
    private Long memberIndex;
//    @Builder
    public KafkaMemberNotificationMessageRequestDto(Long memberIndex, String title, String body) {
        super(title, body);
        this.memberIndex = memberIndex;
    }
}
