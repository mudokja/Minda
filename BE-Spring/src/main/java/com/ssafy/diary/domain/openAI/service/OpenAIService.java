package com.ssafy.diary.domain.openAI.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.diary.domain.advice.entity.Advice;
import com.ssafy.diary.domain.advice.repository.AdviceRepository;
import com.ssafy.diary.domain.analyze.entity.Analyze;
import com.ssafy.diary.domain.analyze.repository.AnalyzeRepository;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import com.ssafy.diary.domain.diary.repository.DiaryRepository;
import com.ssafy.diary.domain.diary.repository.ImageRepository;
import com.ssafy.diary.domain.openAI.dto.*;
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

        ChatGPTRequestDto request = chatGPTRequestGenerator(diary.getDiaryTitle(),analyze, emotionDeque);
        return webClient.post()
                .uri(apiURL + "chat/completions")
                .header("Authorization", "Bearer " + openAIApiKey)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(ChatGPTResponseDto.class)
                .doOnNext(chatGPTResponseDto -> {
                    String advice = chatGPTResponseDto.getChoices().get(0).getMessage().getContent();
                    ObjectMapper objectMapper = new ObjectMapper();
                    ChatGPTResponseMessage message;
                    try {
                        message = objectMapper.readValue(advice, ChatGPTResponseMessage.class);
                    } catch (JsonProcessingException e) {
                        throw new RuntimeException("failed advice to convert to ChatGPTResponseDto");
                    }
                    log.info("advice = {}", advice);
                    adviceRepository.save(Advice.builder()
                            .memberIndex(memberIndex)
                            .startDate(diary.getDiarySetDate())
                            .endDate(diary.getDiarySetDate())
                            .adviceContent(message.getAdvice())
                            .adviceComment(message.getComment())
                            .build());
                });
    }

    private ChatGPTRequestDto chatGPTRequestGenerator(String diaryTitle, Analyze analyze, Deque<String> emotionDeque) {
        List<Message> prompts = new ArrayList<>();
        prompts.add(new Message("system", "1. 당신은 친절한 심리상담 전문가입니다."));
        prompts.add(new Message("system", "2. 제공되는 일기와 감정 분석 결과를 보고 일기 작성자에게 분석과 조언을 해주세요."));
        prompts.add(new Message("system", "3. 일기는 하나이지만 문장별로 감정 분석 결과(완벽히 신뢰할 수는 없음)가 제공됩니다."));
        prompts.add(new Message("system", "4. 일기 작성자에 대한 호칭은 생략하세요."));
        prompts.add(new Message("system", "5. 일기 작성자가 당신이 심리상담 전문가라는 것을 알 필요는 없습니다. 친구와 대화한다는 말투로 부드럽게 이야기하세요."));
        prompts.add(new Message("system", "6. 기본적으로 한국어로 답변하지만, 다른 언어임이 분명할 경우 해당 언어로 답해도 좋습니다."));
        prompts.add(new Message("system", "7. 일기 작성자는 당신과 직접적으로 대화할 수 없습니다. 대화를 하는 듯한 문장은 혼잣말이라고 생각하세요."));
        prompts.add(new Message("system", "8. 심리적으로 우려되는 부분이 있다면 일기 작성자에게 그 부분을 분석적으로 이야기 해주세요"));
        prompts.add(new Message("system", "9. 가장 중요! 당신은 다음에 이 분석들을 모아서 주간 또는 월간 분석을 해줘야 할 수 있습니다. 응답형식을 json 형식으로 하여 { advice: {일기 작성자 에 대한 조언}, comment:{다음 분석시 활용할 요점 코멘트} } 와 같이 응답하세요."));

        prompts.add(new Message("user","제목 :"+diaryTitle));
        for (String sentence : analyze.getSentence()) {
            prompts.add(new Message("user", sentence));
            prompts.add(new Message("assistant", "(분석감정:"+emotionDeque.poll()+")"));

        }
        return new ChatGPTRequestDto(gptModel, prompts);
    }

    private ChatGPTRequestDto oldChatGPTRequestGenerator(Analyze analyze, Deque<String> emotionDeque) {
        String prompt = "일기와 그 일기를 AI에 넣은 감정 분석 결과야. 감정 분석 결과를 참고해서 일기 작성자에게 조언을 해 줘. 일기 하나하나에 대한 개별적인 조언이 아니라, 모든 일기들을 종합해서 조언을 해 줘. 친구에게 이야기하는 듯한 말투로 부드러운 어조로 조언을 해 줘. 호칭은 생략해 줘.\n";
        for(String sentence: analyze.getSentence()){
            prompt+=sentence + "(분석 감정:" + emotionDeque.poll() + ")\n";}

        return new ChatGPTRequestDto(gptModel, prompt);
    }

    @Transactional
    public Mono<ChatGPTResponseDto> generatePeriodAdvice(Long memberIndex, LocalDate startDate, LocalDate endDate) {
        List<Diary> diaryList = diaryRepository.findByMemberIndexAndDiarySetDateOrderByDiarySetDate(memberIndex, startDate, endDate);
        List<Long> diaryIndexList = diaryList.stream().map(Diary::getDiaryIndex).collect(Collectors.toList());
        List<Analyze> analyzeList = analyzeRepository.findByDiaryIndexIn(diaryIndexList);

        String prompt = "일기를 AI에 넣은 감정 분석 결과와 그 일기에서 krwordrank로 추출한 키워드야. 감정 분석 결과와 키워드를 참고해서 일기 작성자에게 조언을 해 줘. 친구에게 이야기하는 듯한 말투로 부드러운 어조로 조언을 해 줘. 호칭은 생략해 줘. \n";
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
//            prompt += "키워드: " + analyzeList.get(i).getKeyword().toString() + "\n";
        }
        log.info("prompt={}", prompt);

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
                            .startDate(startDate)
                            .endDate(endDate)
                            .adviceContent(advice).
                            build());
                });
    }

    @Transactional
    public String generateImage(Long diaryIndex, Long memberIndex) {
        if (imageRepository.existsByDiaryIndex(diaryIndex)) {
            throw new AlreadyExistsImageException("이미 이미지가 존재합니다.");
        }
        Diary diary = diaryRepository.findById(diaryIndex).orElseThrow(() -> new IllegalArgumentException("존재하지 않는 다이어리입니다."));
        if (diary.getMemberIndex() != memberIndex) {
            throw new IllegalArgumentException("일기 작성자의 요청이 아닙니다.");
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
            imageRepository.save(Image.builder()
                    .diaryIndex(diaryIndex)
                    .imageLink(s3ImageUrl)
                    .imageName("AI").build());
            return s3ImageUrl;
        } catch (IOException e) {
            return e.getMessage();
        }
    }
}
