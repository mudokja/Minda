package com.ssafy.diary.domain.advice.dto;

import jakarta.persistence.Column;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class AdviceResponseDto {
    private Long adviceIndex;

    private LocalDateTime startDate;

    private LocalDateTime endDate;

    private String adviceContent;

    @Builder
    public AdviceResponseDto(Long adviceIndex, LocalDateTime startDate, LocalDateTime endDate, String adviceContent) {
        this.adviceIndex = adviceIndex;
        this.startDate = startDate;
        this.endDate = endDate;
        this.adviceContent = adviceContent;
    }
}
