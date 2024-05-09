package com.ssafy.diary.domain.openAI.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatGPTResponse {
    private String id,object,model;
    private LocalDate created;
    private List<Choice> choices;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Choice {
        private Long index;
        private Message message;
        @JsonProperty("finish_reason")
        private String finishReason;
    }

    @Data
    public static class Usage{
        @JsonProperty("prompt_tokens")
        private String promptTokens;
        @JsonProperty("completion_tokens")
        private String completionTokens;
        @JsonProperty("total_tokens")
        private String totalTokens;
    }
}