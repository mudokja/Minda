package com.ssafy.diary.domain.advice.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;

@Getter
@Setter
public class SingleAdviceResponseDto {
    private String[] sentence;
    private List<String> emotion;
    private String adviceContent;
    private HashMap<String,Double> status;

    @Builder
    public SingleAdviceResponseDto(String[] sentence, List<String> emotion, String adviceContent, HashMap<String,Double> status) {
        this.sentence = sentence;
        this.emotion = emotion;
        this.adviceContent = adviceContent;
        this.status = status;
    }
}