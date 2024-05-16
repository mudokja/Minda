package com.ssafy.diary.domain.openAI.service;

import com.ssafy.diary.domain.advice.dto.AdviceRequestDto;
import com.ssafy.diary.domain.advice.entity.Advice;
import com.ssafy.diary.domain.advice.repository.AdviceRepository;
import com.ssafy.diary.domain.analyze.entity.Analyze;
import com.ssafy.diary.domain.analyze.repository.AnalyzeRepository;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import com.ssafy.diary.domain.diary.repository.DiaryRepository;
import com.ssafy.diary.domain.diary.repository.ImageRepository;
import com.ssafy.diary.domain.openAI.dto.ChatGPTRequestDto;
import com.ssafy.diary.domain.openAI.dto.ChatGPTResponseDto;
import com.ssafy.diary.domain.openAI.dto.DallERequestDto;
import com.ssafy.diary.domain.openAI.dto.DallEResponseDto;
import com.ssafy.diary.domain.s3.service.S3Service;
import com.ssafy.diary.global.exception.AlreadyExistsImageException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.io.IOException;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

import static com.ssafy.diary.domain.diary.entity.QDiary.diary;

@Slf4j
@Service
@RequiredArgsConstructor
public class OpenAIService {
    private final DiaryRepository diaryRepository;
    private final ImageRepository imageRepository;
    private final AnalyzeRepository analyzeRepository;
    private final AdviceRepository adviceRepository;
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
    private String[] emotionArray = {"중립", "분노", "슬픔", "놀람", "불안", "기쁨"};
    private String[] totalEmotionArray = {"분노",};

    @Transactional
    public Mono<ChatGPTResponseDto> generateAdvice(Long diaryIndex, Long memberIndex) {
        Analyze analyze = analyzeRepository.findByDiaryIndex(diaryIndex).orElseThrow(() ->
                new IllegalArgumentException("존재하지 않는 다이어리입니다."));

        Diary diary = diaryRepository.findById(diaryIndex).orElseThrow(() -> new IllegalArgumentException("존재하지 않는 다이어리입니다."));
        if (diary.getMemberIndex() != memberIndex) {
            throw new IllegalArgumentException("일기 작성자의 요청이 아닙니다.");
        }

        HashMap<String, Double[]> emotion = analyze.getEmotion();
        Deque<String> emotionDeque = new ArrayDeque<>();

        for (Double[] value : analyze.getEmotion().values()) {
            double max = -100;
            int maxIndex = -1;
            for (int i = 0; i < value.length; i++) {
                if (value[i] > max) {
                    max = value[i];
                    maxIndex = i;
                }
            }
            emotionDeque.add(emotionArray[maxIndex]);
        }

        String prompt = "일기와 그 일기를 AI에 넣은 감정 분석 결과야. 감정 분석 결과를 참고해서 일기 작성자에게 조언을 해 줘. 일기 하나하나에 대한 개별적인 조언이 아니라, 모든 일기들을 종합해서 조언을 해 줘. 친구에게 이야기하는 듯한 말투로 부드러운 어조로 조언을 해 줘. 호칭은 생략해 줘.\n";
        for(String sentence: analyze.getSentence()){
            prompt+=sentence + "(분석 감정:" + emotionDeque.poll() + ")\n";}

        ChatGPTRequestDto request = new ChatGPTRequestDto(gptModel, prompt);
        return webClient.post()
                .uri(apiURL + "chat/completions")
                .header("Authorization", "Bearer " + openAIApiKey)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(ChatGPTResponseDto.class)
                .doOnNext(chatGPTResponseDto -> {
                    String advice = chatGPTResponseDto.getChoices().get(0).getMessage().getContent();
                    log.info("advice = {}", advice);
                    adviceRepository.save(Advice.builder()
                            .memberIndex(memberIndex)
                            .startDate(diary.getDiarySetDate())
                            .endDate(diary.getDiarySetDate())
                            .adviceContent(advice).
                            build());
                });
    }

    @Transactional
    public Mono<ChatGPTResponseDto> generatePeriodAdvice(Long memberIndex, LocalDate startDate, LocalDate endDate) {
        List<Diary> diaryList = diaryRepository.findByMemberIndexAndDiarySetDateOrderByDiarySetDate(memberIndex, startDate, endDate);
        List<Long> diaryIndexList = diaryList.stream().map(Diary::getDiaryIndex).collect(Collectors.toList());
        List<Analyze> analyzeList = analyzeRepository.findByDiaryIndexIn(diaryIndexList);

        String prompt = "일기를 AI에 넣은 감정 분석 결과와 그 일기에서 krwordrank로 추출한 키워드야. 감정 분석 결과와 키워드를 참고해서 일기 작성자에게 조언을 해 줘. 일기 리스트의 일기 하나하나마다 개별적으로 조언하지 말고, 모든 일기를 다 읽은 뒤 종합해서 조언을 해 줘. 친구에게 이야기하는 듯한 말투로 부드러운 어조로 조언을 해 줘. 호칭은 생략해 줘. \n";
        for (int i = 0; i < diaryList.size(); i++) {
            prompt += (i + 1) + "번 일기\n";
            Diary curDiary = diaryList.get(i);
            double[] emotionValues = {
                    curDiary.getDiaryAnger(),
                    curDiary.getDiarySadness(),
                    curDiary.getDiarySurprise(),
                    curDiary.getDiaryFear(),
                    curDiary.getDiaryHappiness()
            };
            double max = -100;
            int maxIndex = -1;
            for (int j = 0; j < emotionValues.length; j++) {
                if (emotionValues[j] > max) {
                    max = emotionValues[j];
                    maxIndex = j;
                }
            }
            prompt += "감정: " + emotionArray[maxIndex + 1] + "\n";
            prompt += "키워드: " + analyzeList.get(i).getKeyword().toString() + "\n";
        }
        log.info("prompt={}", prompt);

        ChatGPTRequestDto request = new ChatGPTRequestDto(gptModel, prompt);
        return webClient.post()
                .uri(apiURL + "chat/completions")
                .header("Authorization", "Bearer " + openAIApiKey)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(ChatGPTResponseDto.class)
//                .doOnNext(chatGPTResponseDto -> {
//                    String advice = chatGPTResponseDto.getChoices().get(0).getMessage().getContent();
//                    log.info("advice = {}", advice);
//                    adviceRepository.save(Advice.builder()
//                            .memberIndex(memberIndex)
//                            .startDate(startDate)
//                            .endDate(endDate)
//                            .adviceContent(advice).
//                            build());
//                })
                ;
    }

    @Transactional
    public String generateImage(Long diaryIndex, Long memberIndex) {
//        if (imageRepository.existsByDiaryIndex(diaryIndex)) {
//            throw new AlreadyExistsImageException("이미 이미지가 존재합니다.");
//        }
        Diary diary = diaryRepository.findById(diaryIndex).orElseThrow(() -> new IllegalArgumentException("존재하지 않는 다이어리입니다."));
        if (diary.getMemberIndex() != memberIndex) {
            throw new IllegalArgumentException("일기 작성자의 요청이 아닙니다.");
        }

        if(!diary.getImageList().isEmpty()) {
            throw new AlreadyExistsImageException("이미 이미지가 존재합니다.");
        }

        DallERequestDto request = DallERequestDto.builder()
                .model("dall-e-3")
                .prompt(diary.getDiaryContent())
                .n(1)
                .size("1024x1024").build();
        DallEResponseDto response = restTemplate.postForObject(apiURL + "images/generations", request, DallEResponseDto.class);

        if (response == null || response.getData() == null || response.getData().isEmpty()) {
            throw new RuntimeException("Failed to receive a valid response from DALL-E API");
        }
        String imageUrl = response.getData().get(0).getUrl();
        try {
            String s3ImageUrl = s3Service.saveImageFromUrl(imageUrl);
            diary.getImageList().add(Image.builder()
                    .imageLink(s3ImageUrl)
                    .imageName("AI").build());
            diaryRepository.save(diary);
//            imageRepository.save(Image.builder()
//                    .diaryIndex(diaryIndex)
//                    .imageLink(s3ImageUrl)
//                    .imageName("AI").build());
            return s3ImageUrl;
        } catch (IOException e) {
            return e.getMessage();
        }
    }
}
