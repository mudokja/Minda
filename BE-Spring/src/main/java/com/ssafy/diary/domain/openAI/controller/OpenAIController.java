package com.ssafy.diary.domain.openAI.controller;

import com.ssafy.diary.domain.openAI.dto.ChatGPTRequest;
import com.ssafy.diary.domain.openAI.dto.ChatGPTResponse;
import com.ssafy.diary.domain.openAI.dto.DallERequest;
import com.ssafy.diary.domain.openAI.dto.ImageClient;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@Tag(name = "OpenAI", description = "GPT API")
@RestController
@RequestMapping("api/openAI")
public class OpenAIController {
    @Value("${openai.model}")
    private String model;

    @Value("${openai.api.url}")
    private String apiURL;

    @Value("${openai.api.key}")
    private String apiKey;

    @Autowired
    private RestTemplate restTemplate;

//    private final ImageClient imageClient;
    @GetMapping
    public String chat(@RequestParam String prompt){
        ChatGPTRequest request = new ChatGPTRequest(model, prompt);
        ChatGPTResponse chatGPTResponse =  restTemplate.postForObject(apiURL+"chat/completions", request, ChatGPTResponse.class);
        return chatGPTResponse.getChoices().get(0).getMessage().getContent();
    }

    @GetMapping("/image")
    public Object image(@RequestParam String prompt){

//        restTemplate.postForObject(apiURL+"chat/completions", request, ChatGPTResponse.class);
        DallERequest request = DallERequest.builder().prompt(prompt).n(1).size("512x512").build();
        return restTemplate.postForObject(apiURL+"images/generations", request, String.class);
    }
}
