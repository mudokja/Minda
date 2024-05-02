package com.ssafy.diary.domain.analyze.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class AnalyzeRequestDto {

    private Long diary_index;
    private String diary_content;

    @Builder
    public AnalyzeRequestDto(Long diaryIndex, String diaryContent) {
        this.diary_index = diaryIndex;
        this.diary_content = diaryContent;
    }
}
