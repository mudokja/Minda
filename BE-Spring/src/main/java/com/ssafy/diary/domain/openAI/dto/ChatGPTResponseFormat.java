package com.ssafy.diary.domain.openAI.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChatGPTResponseFormat {
    private String type;
    @Builder
    public ChatGPTResponseFormat(String type) {
        this.type = type;
    }
}
