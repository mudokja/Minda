package com.ssafy.diary.domain.openAI.service;

import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import com.ssafy.diary.domain.diary.repository.DiaryRepository;
import com.ssafy.diary.domain.diary.repository.ImageRepository;
import com.ssafy.diary.domain.openAI.dto.DallERequest;
import com.ssafy.diary.global.exception.AlreadyExistsImageException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import javax.swing.text.html.Option;

@Service
@RequiredArgsConstructor
public class OpenAIService {
    private final DiaryRepository diaryRepository;
    private final ImageRepository imageRepository;

    @Value("${openai.api.url}")
    private String apiURL;

    @Autowired
    private RestTemplate restTemplate;

    public String generateImage(Long diaryIndex){
        if(imageRepository.existsByDiaryIndex(diaryIndex)){
          throw new AlreadyExistsImageException("이미 이미지가 존재합니다.");
        }
        Diary diary = diaryRepository.findById(diaryIndex).orElseThrow(()-> new IllegalArgumentException("존재하지 않는 다이어리입니다."));
        DallERequest request = DallERequest.builder().prompt(diary.getDiaryContent()).n(1).size("512x512").build();
        return restTemplate.postForObject(apiURL+"images/generations", request, String.class);
    }
}
