package com.ssafy.diary.domain.email.dto;

import lombok.*;
import org.springframework.stereotype.Service;

@Getter
@ToString
@Setter
@NoArgsConstructor
public class KafkaEmailAuthDto {
    private String email;
    private String verificationId;
    private String code;

    @Builder
    public KafkaEmailAuthDto(String email, String verificationId, String code) {
        this.email = email;
        this.verificationId = verificationId;
        this.code = code;
    }
}
