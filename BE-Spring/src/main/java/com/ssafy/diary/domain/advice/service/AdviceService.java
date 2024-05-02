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
import com.ssafy.diary.global.exception.DiaryNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AdviceService {

    private final DiaryRepository diaryRepository;
    private final AdviceRepository adviceRepository;
    private final AnalyzeRepository analyzeRepository;

    private String[] emotionArray = {"중립","분노","슬픔","놀람","불안","기쁨"};

    public SingleAdviceResponseDto getAdvice(Long memberIndex, SingleAdviceRequestDto singleAdviceRequestDto){
        Diary diary = diaryRepository.findByMemberIndexAndDiarySetDate(memberIndex,singleAdviceRequestDto.getDate())
                .orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다."));
        Long diaryIndex = diary.getDiaryIndex();
        Analyze analyze = analyzeRepository.findById(diaryIndex)
                .orElseThrow(()-> new IllegalStateException("분석 결과가 없습니다."));

        HashMap<String,Double[]> emotion = analyze.getEmotion();
        List<String> emotionList = new ArrayList<>();

        for(Double[] key:emotion.values()){
            double max = -100;
            int maxIndex = -1;
            for(int i=0;i<key.length;i++){
                if(key[i]>max){
                    max = key[i];
                    maxIndex = i;
                }
            }
            emotionList.add(emotionArray[maxIndex]);
        }

        return SingleAdviceResponseDto.builder()
                .sentence(analyze.getSentence())
                .emotion(emotionList)
                .adviceContent("null").build();
    }

    public AdviceResponseDto getAdviceByPeriod(Long memberIndex, AdviceRequestDto adviceRequestDto) {
        Advice advice = adviceRepository.findByMemberIndexAndPeriod(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate());
        return advice.toDto();
    }
}
