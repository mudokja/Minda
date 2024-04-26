package com.ssafy.diary.domain.diary.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class DiaryListByPeriodRequestDto {

    private Long memberIndex;
    private LocalDateTime startDate;
    private LocalDateTime endDate;

    @Builder
    public DiaryListByPeriodRequestDto(Long memberIndex, LocalDateTime startDate, LocalDateTime endDate) {
        this.memberIndex = memberIndex;
        this.startDate = startDate;
        this.endDate = endDate;
    }
}
