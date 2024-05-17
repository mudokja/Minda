package com.ssafy.diary.domain.openAI.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Data
public class ChatGPTRequestDto {
    private String model;
    private List<Message> messages;
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private ChatGPTResponseFormat response_format;

    public ChatGPTRequestDto(String model, String prompt) {
        this.model = model;
        this.messages =  new ArrayList<>();
        this.messages.add(new Message("user", prompt));
    }
    public ChatGPTRequestDto(String model, List<Message> prompts, String type) {
        this.model = model;
        this.messages = prompts;
        this.response_format = ChatGPTResponseFormat.
                builder()
                .type(type)
                .build();
    }
    public ChatGPTRequestDto(String model, List<Message> prompts) {
        this.model = model;
        this.messages = prompts;
    }

}