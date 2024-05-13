package com.ssafy.diary.domain.analyze.service;

import com.ssafy.diary.domain.analyze.dto.AnalyzeRequestDto;
import com.ssafy.diary.domain.analyze.entity.Analyze;
import com.ssafy.diary.domain.analyze.repository.AnalyzeRepository;
import com.ssafy.diary.domain.diary.entity.Diary;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class AnalyzeService {
    private final AnalyzeRepository analyzeRepository;
    @Qualifier("webClient")
    private final WebClient webClient;

    public Mono<String> addAnalyze(AnalyzeRequestDto analyzeRequestDto){
        return requestAnalyzeToFastAPI(analyzeRequestDto);
    }
    public Analyze getAnalyze(Long diaryIndex){
        return analyzeRepository.findByDiaryIndex(diaryIndex).orElse(null);
    }

    public void calculateEmotionPoints(Diary diary) {

        Analyze analyze = this.getAnalyze(diary.getDiaryIndex());
        HashMap<String, Double[]> emotion = analyze.getEmotion();
        String[] sentence = analyze.getSentence();

        if (diary.getDiaryHappiness() == null) {
            double[] sumArray = new double[5];
            //emotion: 문장별 감정 수치 리스트
            //value: 문장 하나의 감정별 수치 리스트
            //sumArray: 감정별 합계 리스트
            for (Double[] value : emotion.values()) {
                for (int i = 1; i < value.length; i++) {
                    sumArray[i - 1] += value[i];
                }
            }
            log.info("array={}", Arrays.toString(sumArray));
            log.info("sentence={}", analyze.getSentence().length);
            for (int i = 0; i < sumArray.length; i++)
                sumArray[i] /= analyze.getSentence().length;

            diary.setDiaryAnger(sumArray[0]);
            diary.setDiarySadness(sumArray[1]);
            diary.setDiarySurprise(sumArray[2]);
            diary.setDiaryFear(sumArray[3]);
            diary.setDiaryHappiness(sumArray[4]);
        }
    }


//    public void addAnalyze(){
//        Analyze analyze = Analyze.builder().diaryIndex(11L).emotion(null).build();
//        analyzeRepository.save(analyze);
//    }
    public void updateAnalyze(){
    }
    public void removeAnalyze(){
    }

    //Fast API로 요청 보내기
//    public Mono<AnalyzeRequestDto> requestAnalyzeToFastlAPI(AnalyzeRequestDto analyzeRequestDto) {
//        return (Mono<AnalyzeRequestDto>) webClient.post()
//                .uri("/analyze")
//                .bodyValue(analyzeRequestDto)
//                .retrieve()
//                .bodyToMono(AnalyzeRequestDto.class)
//                .subscribe(body -> {
//                    System.out.println("Response from External API: " + body);
//                    // 받은 데이터 처리하는 로직
//                });
//    }

    //Fast API로 요청 보내기
    public Mono<String> requestAnalyzeToFastAPI(AnalyzeRequestDto analyzeRequestDto) {
        return webClient.post()
                .uri("https://k10b205.p.ssafy.io/api/ai/analyze")
//                .uri(uriBuilder -> uriBuilder
//                        .path("/analyze")
//                        .queryParam("diary_index", analyzeRequestDto.getDiaryIndex())
//                        .queryParam("diary_content", analyzeRequestDto.getDiaryContent())
//                        .build())
                .bodyValue(analyzeRequestDto)
                .retrieve()
//                .bodyToMono(AnalyzeResponseDto.class)
                .bodyToMono(String.class)
//                .bodyToMono(Analyze.class)
                .doOnNext(body -> {
                    System.out.println("Response from External API: " + body);
                    // 받은 데이터 처리하는 로직
                });
    }

}
