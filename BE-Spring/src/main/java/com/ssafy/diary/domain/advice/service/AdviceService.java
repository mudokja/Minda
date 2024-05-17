package com.ssafy.diary.domain.advice.service;

import com.ssafy.diary.domain.advice.dto.AdviceRequestDto;
import com.ssafy.diary.domain.advice.dto.AdviceResponseDto;
import com.ssafy.diary.domain.advice.dto.SingleAdviceRequestDto;
import com.ssafy.diary.domain.advice.dto.SingleAdviceResponseDto;
import com.ssafy.diary.domain.advice.entity.Advice;
import com.ssafy.diary.domain.advice.repository.AdviceRepository;
import com.ssafy.diary.domain.analyze.entity.Analyze;
import com.ssafy.diary.domain.analyze.repository.AnalyzeRepository;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.repository.DiaryRepository;
import com.ssafy.diary.domain.openAI.dto.ChatGPTResponseDto;
import com.ssafy.diary.domain.openAI.service.OpenAIService;
import com.ssafy.diary.domain.s3.service.S3Service;
import com.ssafy.diary.global.exception.DiaryNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdviceService {

    private final DiaryRepository diaryRepository;
    private final AdviceRepository adviceRepository;
    private final AnalyzeRepository analyzeRepository;
    private final OpenAIService openAIService;
    private final S3Service s3Service;

    @Value("${app.baseurl.ai}")
    private String aiBaseUrl;

    @Autowired
    private final WebClient webClient;

    private String[] emotionArray = {"중립", "분노", "슬픔", "놀람", "불안", "기쁨"};

    @Transactional
    public SingleAdviceResponseDto getAdvice(Long memberIndex, SingleAdviceRequestDto singleAdviceRequestDto) {
        Diary diary = diaryRepository.findByMemberIndexAndDiarySetDate(memberIndex, singleAdviceRequestDto.getDate())
                .orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다."));

        Long diaryIndex = diary.getDiaryIndex();
        Analyze analyze = analyzeRepository.findByDiaryIndex(diaryIndex)
                .orElseThrow(() -> new IllegalStateException("저장된 분석 결과가 없습니다."));

        HashMap<String, Double[]> emotion = analyze.getEmotion();
        List<String> emotionList = new ArrayList<>();

        for (Double[] value : emotion.values()) {
            double max = -100;
            int maxIndex = -1;
            for (int i = 0; i < value.length; i++) {
                if (value[i] > max) {
                    max = value[i];
                    maxIndex = i;
                }
            }
            emotionList.add(emotionArray[maxIndex]);
        }
        HashMap<String, Double> statusMap = new HashMap<>();

        statusMap.put("분노", diary.getDiaryAnger());
        statusMap.put("슬픔", diary.getDiarySadness());
        statusMap.put("놀람", diary.getDiarySurprise());
        statusMap.put("불안", diary.getDiaryFear());
        statusMap.put("기쁨", diary.getDiaryHappiness());

        Optional<Advice> advice = adviceRepository.findByMemberIndexAndPeriod(memberIndex, singleAdviceRequestDto.getDate(), singleAdviceRequestDto.getDate());

        String adviceContent = "조언을 생성하는 중입니다. 분석 완료 알림이 오면 다시 확인해주세요.";
        if (advice.isPresent()) {
            adviceContent = advice.get().getAdviceContent();
        }

        return SingleAdviceResponseDto.builder()
                .sentence(analyze.getSentence())
                .emotion(emotionList)
                .adviceContent(adviceContent)
                .status(statusMap).build();
    }

    @Transactional
    public AdviceResponseDto getAdviceByPeriod(Long memberIndex, AdviceRequestDto adviceRequestDto) {

        List<Diary> diaryList = diaryRepository.findByMemberIndexAndDiarySetDateOrderByDiarySetDate(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate());

        if (diaryList == null || diaryList.isEmpty()) {
            return AdviceResponseDto.builder()
                    .adviceContent("다이어리가 없습니다.")
                    .status(new HashMap<>()) // 빈 상태의 statusMap 반환
                    .build();
        }

        HashMap<String, Double> statusMap = new HashMap<>();

        for (Diary diary : diaryList) {

            // statusMap에 각 다이어리의 감정값을 누적하여 넣습니다.
            statusMap.put("분노", statusMap.getOrDefault("분노", 0.0) + diary.getDiaryAnger());
            statusMap.put("슬픔", statusMap.getOrDefault("슬픔", 0.0) + diary.getDiarySadness());
            statusMap.put("놀람", statusMap.getOrDefault("놀람", 0.0) + diary.getDiarySurprise());
            statusMap.put("불안", statusMap.getOrDefault("불안", 0.0) + diary.getDiaryFear());
            statusMap.put("기쁨", statusMap.getOrDefault("기쁨", 0.0) + diary.getDiaryHappiness());
        }

        // 다이어리들의 감정값을 평균내어 statusMap에 넣습니다.
        int diaryCount = diaryList.size();
        if (diaryCount > 0) {
            statusMap.put("분노", statusMap.getOrDefault("분노", 0.0) / diaryCount);
            statusMap.put("슬픔", statusMap.getOrDefault("슬픔", 0.0) / diaryCount);
            statusMap.put("놀람", statusMap.getOrDefault("놀람", 0.0) / diaryCount);
            statusMap.put("불안", statusMap.getOrDefault("불안", 0.0) / diaryCount);
            statusMap.put("기쁨", statusMap.getOrDefault("기쁨", 0.0) / diaryCount);
        }

        Optional<Advice> optionalAdvice = adviceRepository.findByMemberIndexAndPeriod(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate());

        if (!optionalAdvice.isPresent()) {
//            imageLink = String.valueOf(getWordcloudByPeriod(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate()));
//            ChatGPTResponseDto chatGPTResponseDto = openAIService.generatePeriodAdvice(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate()).block();
//
//            adviceContent = chatGPTResponseDto.getChoices().get(0).getMessage().getContent();
//            log.info("advice = {}", adviceContent);
//            adviceRepository.save(Advice.builder()
//                    .memberIndex(memberIndex)
//                    .startDate(adviceRequestDto.getStartDate())
//                    .endDate(adviceRequestDto.getEndDate())
//                    .adviceContent(adviceContent)
//                    .imageLink(imageLink)
//                    .build());
//
//            Mono<String> wordcloudMono = getWordcloudByPeriod(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate());
//            Mono<ChatGPTResponseDto> adviceMono = openAIService.generatePeriodAdvice(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate());

            AdviceResponseDto adviceResponseDto = getAdviceAndWordCloud(memberIndex, adviceRequestDto).block();
            adviceResponseDto.setStatus(statusMap);
            return adviceResponseDto;
//            Mono.zip(wordcloudMono, adviceMono)
//                    .flatMap(tuple -> {
//                        Advice advice = adviceRepository.findByMemberIndexAndPeriod(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate()).get();
//                        String imageLink = tuple.getT1();
//                        String adviceContent = advice.getAdviceContent();
//
//                        advice.updateImageLink(imageLink);
//                        adviceRepository.save(advice);
//
//                        return Mono.just(AdviceResponseDto.builder()
//                                .adviceContent(adviceContent)
//                                .imageLink(imageLink)
//                                .status(statusMap)
//                                .build());
//                    });
//
//            Mono.zip(wordcloudMono, adviceMono).subscribe(tuple -> {
//                Advice advice = adviceRepository.findByMemberIndexAndPeriod(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate()).get();
//                String imageLink = tuple.getT1();
//                String adviceContent = advice.getAdviceContent();
//
//                advice.updateImageLink(imageLink);
//                adviceRepository.save(advice);
//
//                return AdviceResponseDto.builder()
//                        .adviceContent(adviceContent)
//                        .imageLink(imageLink)
//                        .status(statusMap).build();
//            });
        }

        String adviceContent = optionalAdvice.get().getAdviceContent();
        String imageLink = optionalAdvice.get().getImageLink();

        return AdviceResponseDto.builder()
                .adviceContent(adviceContent)
                .imageLink(imageLink)
                .status(statusMap).build();
    }

    private Mono<AdviceResponseDto> getAdviceAndWordCloud(Long memberIndex, AdviceRequestDto adviceRequestDto) {
        Mono<String> wordcloudMono = getWordcloudByPeriod(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate());
        Mono<ChatGPTResponseDto> adviceMono = openAIService.generatePeriodAdvice(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate());

        return Mono.zip(wordcloudMono, adviceMono)
                .flatMap(tuple -> {
                    Advice advice = adviceRepository.findByMemberIndexAndPeriod(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate()).get();
                    String imageLink = tuple.getT1();
                    String adviceContent = advice.getAdviceContent();

                    advice.updateImageLink(imageLink);
                    adviceRepository.save(advice);

                    return Mono.just(AdviceResponseDto.builder()
                            .adviceContent(adviceContent)
                            .imageLink(imageLink)
                            .build());
                });
    }

    @Transactional
    public void updateAdviceByPeriod(Long memberIndex, LocalDate diarySetDate) {
        List<Advice> adviceList = adviceRepository.findAdvicesByMemberIndexAndDate(memberIndex, diarySetDate);

        if (adviceList != null && !adviceList.isEmpty()) {
            for (Advice advice : adviceList) {
                List<Diary> diaryList = diaryRepository.findByMemberIndexAndDiarySetDateOrderByDiarySetDate(memberIndex, advice.getStartDate(), advice.getEndDate());
                s3Service.deleteImageFromS3(advice.getImageLink());
                adviceRepository.deleteByMemberIndexAndDate(memberIndex, advice.getStartDate(), advice.getEndDate());

                if (diaryList != null && !diaryList.isEmpty()) {
                    Mono<String> wordcloudMono = getWordcloudByPeriod(memberIndex, advice.getStartDate(), advice.getEndDate());
                    Mono<ChatGPTResponseDto> adviceMono = openAIService.generatePeriodAdvice(memberIndex, advice.getStartDate(), advice.getEndDate());

                    Mono.zip(wordcloudMono, adviceMono).subscribe(tuple -> {
                        Advice newAdvice = adviceRepository.findByMemberIndexAndPeriod(memberIndex, advice.getStartDate(), advice.getEndDate()).get();
                        String imageLink = tuple.getT1();
                        newAdvice.updateImageLink(imageLink);
                        adviceRepository.save(newAdvice);
                    });

//                    Mono<ChatGPTResponseDto> chatGPTResponseDto = openAIService.generatePeriodAdvice(memberIndex, advice.getStartDate(), advice.getEndDate());
//
//                    getWordcloudByPeriod(memberIndex, advice.getStartDate(), advice.getEndDate()).subscribe(imageLink -> {
//                        openAIService.generatePeriodAdvice(memberIndex, advice.getStartDate(), advice.getEndDate()).subscribe(responseDto -> {
//                            String adviceContent = responseDto.getChoices().get(0).getMessage().getContent();
//                            Advice newAdvice = Advice.builder()
//                                    .memberIndex(memberIndex)
//                                    .startDate(advice.getStartDate())
//                                    .endDate(advice.getEndDate())
//                                    .adviceContent(adviceContent)
//                                    .imageLink(imageLink)
//                                    .build();
//                            adviceRepository.save(newAdvice);
//                        });
//                    });

//                    String imageLink = getWordcloudByPeriod(memberIndex, advice.getStartDate(), advice.getEndDate()).block();
//                    ChatGPTResponseDto chatGPTResponseDto = openAIService.generatePeriodAdvice(memberIndex, advice.getStartDate(), advice.getEndDate()).block();
//
//                    String adviceContent = chatGPTResponseDto.getChoices().get(0).getMessage().getContent();
//                    log.info("advice = {}", advice);
//                    advice.updateImageLink(imageLink);
//                        adviceRepository.save(advice);
//                    adviceRepository.save(Advice.builder()
//                            .memberIndex(memberIndex)
//                            .startDate(advice.getStartDate())
//                            .endDate(advice.getEndDate())
//                            .adviceContent(adviceContent)
//                            .imageLink(imageLink)
//                            .build());

                }
            }
        }
    }


    public Mono<String> getWordcloudByPeriod(Long memberIndex, LocalDate startDate, LocalDate endDate) {
        List<Diary> diaryList = diaryRepository.findByMemberIndexAndDiarySetDateOrderByDiarySetDate(memberIndex, startDate, endDate);
        List<Integer> diaryIndexList = diaryList.stream().map(Diary::getDiaryIndex).map(Long::intValue).collect(Collectors.toList());

        Map<String, List<Integer>> payload = new HashMap<>();
        payload.put("diary_index_list", diaryIndexList);

        return webClient.post()
                .uri(aiBaseUrl + "/api/ai/wordcloud")
                .bodyValue(payload)
                .retrieve()
                .bodyToMono(String.class)
                .map(url -> url.replaceAll("^\"|\"$", ""))
                .filter(url -> !url.isEmpty())  // 유효하지 않은 URL 필터링
                .defaultIfEmpty("default-image-url.png")  // 기본 이미지 URL 제공
                .doOnNext(url -> log.info("Wordcloud URL retrieved: {}", url))
                .doOnError(error -> log.error("Error retrieving wordcloud URL", error));
    }

}
