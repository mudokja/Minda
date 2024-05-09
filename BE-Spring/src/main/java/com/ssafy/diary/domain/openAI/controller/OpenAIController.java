package com.ssafy.diary.domain.openAI.controller;

import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.openAI.dto.ChatGPTRequestDto;
import com.ssafy.diary.domain.openAI.dto.ChatGPTResponseDto;
import com.ssafy.diary.domain.openAI.service.OpenAIService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@Tag(name = "OpenAI", description = "GPT API")
@RestController
@RequestMapping("api/openAI")
@RequiredArgsConstructor
public class OpenAIController {
    @Value("${openai.model}")
    private String model;
    @Value("${openai.api.url}")
    private String apiURL;
    @Value("${openai.api.key}")
    private String apiKey;
    @Autowired
    private RestTemplate restTemplate;

    private final OpenAIService openAIService;

//    private final ImageClient imageClient;
    @GetMapping
    public String chat(@RequestParam String prompt){
        ChatGPTRequestDto request = new ChatGPTRequestDto(model, prompt);
        ChatGPTResponseDto chatGPTResponse =  restTemplate.postForObject(apiURL+"chat/completions", request, ChatGPTResponseDto.class);
        return chatGPTResponse.getChoices().get(0).getMessage().getContent();
    }

    @GetMapping("/chatGPT/test")
    public String advice(@AuthenticationPrincipal PrincipalMember member, @RequestParam Long diaryIndex){
        Long memberIndex = member.getIndex();
        openAIService.generateAdvice(diaryIndex,memberIndex).subscribe(body->
                System.out.println("Response from External API on controller: " + body));
        return "success";
    }

    @Operation(summary = "이미지 생성", description = "일기 인덱스를 받아 이미지가 없으면 이미지 생성")
    @GetMapping("/image")
    public ResponseEntity<Object> generateImage(@AuthenticationPrincipal PrincipalMember member, @RequestParam Long diaryIndex){
        Long memberIndex = member.getIndex();
        String s3Url = openAIService.generateImage(diaryIndex,memberIndex);
        return ResponseEntity.ok().body(s3Url);
    }
}
