package com.ssafy.diary.domain.analyze.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class AnalyzeRequestDto {

    private Long diaryIndex;
    private String diaryContent;

    @Builder
    public AnalyzeRequestDto(Long diaryIndex, String diaryContent) {
        this.diaryIndex = diaryIndex;
        this.diaryContent = diaryContent;
    }
}
