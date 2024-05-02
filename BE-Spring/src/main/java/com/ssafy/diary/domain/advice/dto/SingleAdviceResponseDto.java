package com.ssafy.diary.domain.advice.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class SingleAdviceResponseDto {
    private String[] sentence;
    List<String> emotion;
    private String adviceContent;

    @Builder
    public SingleAdviceResponseDto(String[] sentence, List<String> emotion, String adviceContent) {
        this.sentence = sentence;
        this.emotion = emotion;
        this.adviceContent = adviceContent;
    }
}