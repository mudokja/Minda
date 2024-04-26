package com.ssafy.diary.domain.openAI.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class DallERequest {
    private String prompt,size;
    private int n;
}
