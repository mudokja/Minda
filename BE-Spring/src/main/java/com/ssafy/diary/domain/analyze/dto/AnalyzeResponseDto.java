package com.ssafy.diary.domain.analyze.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

import java.util.HashMap;

@Getter
@Setter
public class AnalyzeResponseDto {

    @JsonProperty("diary_index")
    private Long diaryIndex;

    @JsonProperty("sentence")
    private String[] sentence;

    @JsonProperty("emotion")
    private HashMap<String, Double[]> emotion;

    @JsonProperty("keyword")
    private HashMap<String, Double> keyword;

    @JsonProperty("_id")
    private String id;
}
