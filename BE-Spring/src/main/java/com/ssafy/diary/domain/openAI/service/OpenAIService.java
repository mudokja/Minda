package com.ssafy.diary.domain.openAI.service;

import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import com.ssafy.diary.domain.diary.repository.DiaryRepository;
import com.ssafy.diary.domain.diary.repository.ImageRepository;
import com.ssafy.diary.domain.openAI.dto.ChatGPTRequest;
import com.ssafy.diary.domain.openAI.dto.ChatGPTResponse;
import com.ssafy.diary.domain.openAI.dto.DallERequest;
import com.ssafy.diary.domain.openAI.dto.DallEResponse;
import com.ssafy.diary.domain.s3.service.S3Service;
import com.ssafy.diary.global.exception.AlreadyExistsImageException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import javax.swing.text.html.Option;
import java.io.IOException;

@Slf4j
@Service
@RequiredArgsConstructor
public class OpenAIService {
    private final DiaryRepository diaryRepository;
    private final ImageRepository imageRepository;
    private final S3Service s3Service;

    @Autowired
    private final WebClient webClient;

    @Value("${openai.api.url}")
    private String apiURL;
    @Value("${openai.model}")
    private String gptModel;
    @Value("${openai.api.key}")
    private String openAIApiKey;


    @Autowired
    private RestTemplate restTemplate;

    public Mono<ChatGPTResponse> generateAdvice(String prompt, Long memberIndex) {
        ChatGPTRequest request = new ChatGPTRequest(gptModel, prompt);
        return webClient.post()
                .uri(apiURL + "chat/completions")
                .header("Authorization", "Bearer " + openAIApiKey)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(ChatGPTResponse.class)
                .doOnNext(body->{
                    System.out.println("Response from External API: " + body);
                });
    }

    public String generateImage(Long diaryIndex, Long memberIndex) {
        if(imageRepository.existsByDiaryIndex(diaryIndex)){
          throw new AlreadyExistsImageException("이미 이미지가 존재합니다.");
        }
        Diary diary = diaryRepository.findById(diaryIndex).orElseThrow(()-> new IllegalArgumentException("존재하지 않는 다이어리입니다."));
        if(diary.getMemberIndex() != memberIndex){
            throw new IllegalArgumentException("일기 작성자의 요청이 아닙니다.");
        }

        DallERequest request = DallERequest.builder()
                .model("dall-e-3")
                .prompt(diary.getDiaryContent())
                .n(1)
                .size("1024x1024").build();
        DallEResponse response = restTemplate.postForObject(apiURL+"images/generations", request, DallEResponse.class);

        if (response == null || response.getData() == null || response.getData().isEmpty()) {
            throw new RuntimeException("Failed to receive a valid response from DALL-E API");
        }
        String imageUrl = response.getData().get(0).getUrl();
        try {
            String s3ImageUrl = s3Service.saveImageFromUrl(imageUrl);
            imageRepository.save(Image.builder()
                    .diaryIndex(diaryIndex)
                    .imageLink(s3ImageUrl)
                    .imageName("AI").build());
            return s3ImageUrl;
        }catch(IOException e){
            return e.getMessage();
        }
    }
}
