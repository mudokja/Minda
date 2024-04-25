package com.ssafy.diary.domain.diary.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class DiaryListByPeriodRequestDto {

    private LocalDateTime startDate;
    private LocalDateTime endDate;

    @Builder
    public DiaryListByPeriodRequestDto(LocalDateTime startDate, LocalDateTime endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
    }
}
