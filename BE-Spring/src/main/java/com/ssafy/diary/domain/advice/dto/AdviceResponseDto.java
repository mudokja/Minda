package com.ssafy.diary.domain.advice.dto;

import jakarta.persistence.Column;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Map;

@Getter
@Setter
public class AdviceResponseDto {
    private String adviceContent;
    private String imageLink;
    private Map<String, Double> status;

    @Builder
    public AdviceResponseDto(String adviceContent, String imageLink, Map<String, Double> status) {
        this.adviceContent = adviceContent;
        this.imageLink = imageLink;
        this.status = status;
    }
}