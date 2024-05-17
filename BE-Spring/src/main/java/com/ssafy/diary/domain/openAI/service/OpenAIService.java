package com.ssafy.diary.domain.openAI.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.diary.domain.advice.entity.Advice;
import com.ssafy.diary.domain.advice.repository.AdviceRepository;
import com.ssafy.diary.domain.analyze.entity.Analyze;
import com.ssafy.diary.domain.analyze.repository.AnalyzeRepository;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import com.ssafy.diary.domain.diary.repository.DiaryRepository;
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
                        Map<String,Object> data = objectMapper.readValue(advice, new TypeReference<Map<String, Object>>(){});
                        message =  ChatGPTResponseMessage.builder()
                                .advice((String) data.get("advice"))
                                .comment(data.get("comment").toString())
                                .build();
                    } catch (JsonProcessingException e) {
                        log.debug(e.getMessage());
                        throw new RuntimeException("failed advice to convert to ChatGPTResponseDto");
                    }
                    log.debug("advice = {}", advice);
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
        prompts.add(new Message("system", "1. You are a kind psychological counselor."));
        prompts.add(new Message("system", "2. Review the provided diary entries and emotion analysis results, then offer analysis and advice to the diary writer."));
        prompts.add(new Message("system", "3. There is only one diary entry, but emotion analysis results (which may not be completely reliable) are provided for each sentence."));
        prompts.add(new Message("system", "4. Omit any titles or formal address for the diary writer."));
        prompts.add(new Message("system", "5. The diary writer does not need to know that you are a psychological counselor. Speak gently as if talking to a friend."));
        prompts.add(new Message("system", "6. Primarily respond in Korean, but if it is clear that the language is different, feel free to respond in that language."));
        prompts.add(new Message("system", "7. The diary writer cannot communicate with you directly. Treat conversational statements as if talking to yourself."));
        prompts.add(new Message("system", "8. If there are any psychologically concerning aspects, address them analytically with the diary writer."));
        prompts.add(new Message("system", "9. Most importantly! You will need to compile these analyses into a weekly or monthly report. Respond in JSON format as follows: { advice: {advice for the diary writer}, comment: {simple key points and keywords for future analysis} }"));


        prompts.add(new Message("user","제목 :"+diaryTitle));
        for (String sentence : analyze.getSentence()) {
            prompts.add(new Message("user", sentence));
            prompts.add(new Message("assistant", "(분석감정:"+emotionDeque.poll()+")"));

        }
        return new ChatGPTRequestDto(gptModel, prompts,"json_object");
    }
    private ChatGPTRequestDto chatGPTRequestPeriodGenerator(List<Diary> diaryList, List<Analyze> analyzeList, List<Advice> adviceList) {
        List<Message> prompts = new ArrayList<>();
        prompts.add(new Message("system", "1. You are a kind psychological counselor."));
        prompts.add(new Message("system", "2. You will be provided with comments on the last diary entry, the extracted keywords using krwordrank from that entry, and the emotion analysis results."));
        prompts.add(new Message("system", "3. You need to analyze the diaries from a specific period and provide comprehensive analysis and advice to the diary writer."));
        prompts.add(new Message("system", "4. Omit any titles or formal address for the diary writer."));
        prompts.add(new Message("system", "5. The diary writer does not need to know that you are a psychological counselor. Speak gently as if talking to a friend."));
        prompts.add(new Message("system", "6. Primarily respond in Korean, but if it is clear that the language is different, feel free to respond in that language."));
        prompts.add(new Message("system", "7. The diary writer cannot communicate with you directly. Treat conversational statements as if talking to yourself."));
        prompts.add(new Message("system", "8. If there are any psychologically concerning aspects, address them analytically with the diary writer."));
        prompts.add(new Message("system", "Most importantly, the response format for these analyses should be in JSON format as follows: { \"advice\": { \"advice for the diary writer\" }, \"comment\": { \"This is a period analysis\" at the beginning, followed by a brief simple summary of the main keywords } }."));

//        String prompt = "일기를 AI에 넣은 감정 분석 결과와 그 일기에서 krwordrank로 추출한 키워드야. 감정 분석 결과와 키워드를 참고해서 일기 작성자에게 조언을 해 줘. 친구에게 이야기하는 듯한 말투로 부드러운 어조로 조언을 해 줘. 호칭은 생략해 줘. \n";
        for (int i = 0; i < diaryList.size(); i++) {
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
            HashMap<String, Double> keywords = null;
            for (Analyze analyze : analyzeList) {
                if (diaryList.get(i).getDiaryIndex().equals(analyze.getDiaryIndex())) {
                    keywords = analyze.getKeyword();
                }
            }
            String keywordPrompt;
            if(keywords==null||keywords.isEmpty()){
                keywordPrompt="키워드는 없습니다.";
            }else{
                keywordPrompt = "키워드: " + keywords+ "\n";

            }
            String advicePrompt ="";
            for(Advice advice : adviceList){
                if(diaryList.get(i).getDiarySetDate().equals(advice.getStartDate())&& diaryList.get(i).getDiarySetDate().equals(advice.getEndDate())){
                    advicePrompt = advice.getAdviceComment();
                }
            }
            keywordPrompt=keywordPrompt+"\n";
            prompts.add(new Message("assistant",i+"번 일기 \n 감정: " + emotionArray[maxIndex + 1] + "\n" +keywordPrompt + "comment : "+advicePrompt));
        }
        prompts.add(new Message("user","그럼, 이제 기간 동안의 일기 분석 결과를 종합해서 알려주세요."));
        log.debug("prompt={}", prompts);

        return new ChatGPTRequestDto(gptModel, prompts,"json_object");
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
        List<Advice> adviceList = adviceRepository.findByAllMemberIndexAndPeriod(memberIndex,startDate,endDate);
        ChatGPTRequestDto request = chatGPTRequestPeriodGenerator(diaryList,analyzeList,adviceList);
        return webClient.post()
                .uri(apiURL + "chat/completions")
                .header("Authorization", "Bearer " + openAIApiKey)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(ChatGPTResponseDto.class)
                .doOnNext(chatGPTResponseDto -> {
                    String advice = chatGPTResponseDto.getChoices().get(0).getMessage().getContent();
//                    log.debug("내용 " +advice);
                    ObjectMapper objectMapper = new ObjectMapper();
                    ChatGPTResponseMessage message;
                    try {
                        Map<String,Object> data = objectMapper.readValue(advice, new TypeReference<Map<String, Object>>(){});
                        message =  ChatGPTResponseMessage.builder()
                                .advice((String) data.get("advice"))
                                .comment(data.get("comment").toString())
                                .build();
                    } catch (JsonProcessingException e) {
                        throw new RuntimeException("failed advice to convert to ChatGPTResponseDto");
                    }
                    log.debug("advice = {}", advice);
                    adviceRepository.save(Advice.builder()
                            .memberIndex(memberIndex)
                            .startDate(startDate)
                            .endDate(endDate)
                            .adviceContent(message.getAdvice())
                            .adviceComment(message.getComment())
                            .build());
                });
    }

    private ChatGPTRequestDto oldChatGPTRequestPeriodGenerator(List<Diary> diaryList) {
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
        log.debug("prompt={}", prompt);

        ChatGPTRequestDto request = new ChatGPTRequestDto(gptModel, prompt);
        return request;
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
