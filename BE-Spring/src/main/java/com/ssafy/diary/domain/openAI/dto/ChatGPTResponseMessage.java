package com.ssafy.diary.domain.openAI.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
public class ChatGPTResponseMessage implements Serializable {
    private String advice;
    private String comment;
    @Builder
    public ChatGPTResponseMessage(String advice, String comment) {
        this.advice = advice;
        this.comment = comment;
    }
}
