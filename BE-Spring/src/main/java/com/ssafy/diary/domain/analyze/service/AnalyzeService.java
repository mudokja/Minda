package com.ssafy.diary.domain.analyze.service;

import com.ssafy.diary.domain.analyze.dto.AnalyzeRequestDto;
import com.ssafy.diary.domain.analyze.entity.Analyze;
import com.ssafy.diary.domain.analyze.repository.AnalyzeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

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
                .uri("/analyze")
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
