package com.ssafy.diary.domain.diary.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
public class DiaryListByPeriodRequestDto {

    private LocalDate startDate;
    private LocalDate endDate;

    @Builder
    public DiaryListByPeriodRequestDto(LocalDate startDate, LocalDate endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
    }
}
