package com.ssafy.diary.domain.openAI.dto;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Data
public class ChatGPTRequestDto {
    private String model;
    private List<Message> messages;

    public ChatGPTRequestDto(String model, String prompt) {
        this.model = model;
        this.messages =  new ArrayList<>();
        this.messages.add(new Message("user", prompt));
    }
    public ChatGPTRequestDto(String model, List<Message> prompts) {
        this.model = model;
        this.messages = prompts;
    }

}