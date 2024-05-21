package com.ssafy.diary.domain.openAI.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class DallERequestDto {
    private String model,prompt,size;
    private int n;
}
