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
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdviceService {

    private final DiaryRepository diaryRepository;
    private final AdviceRepository adviceRepository;
    private final AnalyzeRepository analyzeRepository;

    private String[] emotionArray = {"중립","분노","슬픔","놀람","불안","기쁨"};

    @Transactional
    public SingleAdviceResponseDto getAdvice(Long memberIndex, SingleAdviceRequestDto singleAdviceRequestDto){
        Diary diary = diaryRepository.findByMemberIndexAndDiarySetDate(memberIndex,singleAdviceRequestDto.getDate())
                .orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다."));
        Long diaryIndex = diary.getDiaryIndex();
        Analyze analyze = analyzeRepository.findByDiaryIndex(diaryIndex)
                .orElseThrow(()-> new IllegalStateException("분석 결과가 없습니다."));

        HashMap<String,Double[]> emotion = analyze.getEmotion();
        List<String> emotionList = new ArrayList<>();

        for(Double[] value:emotion.values()){
            double max = -100;
            int maxIndex = -1;
            for(int i=0;i<value.length;i++){
                if(value[i]>max){
                    max = value[i];
                    maxIndex = i;
                }
            }
            emotionList.add(emotionArray[maxIndex]);
        }
        HashMap<String,Double> statusMap = new HashMap<>();
        if(diary.getDiaryHappiness() == null){
            double[] sumArray = new double[5];
            for(Double[] value:emotion.values()){
                for(int i=1;i<value.length;i++){
                    sumArray[i-1] += value[i];
                }
            }
            log.info("array={}", Arrays.toString(sumArray));
            log.info("sentence={}",analyze.getSentence().length);
            for(int i=0;i<sumArray.length;i++)
                sumArray[i]/=analyze.getSentence().length;
            diary.setDiaryAnger((long)sumArray[0]);
            diary.setDiarySadness((long)sumArray[1]);
            diary.setDiarySurprise((long)sumArray[2]);
            diary.setDiaryFear((long)sumArray[3]);
            diary.setDiaryHappiness((long)sumArray[4]);
        }
        statusMap.put("분노",(double)diary.getDiaryAnger());
        statusMap.put("슬픔",(double)diary.getDiarySadness());
        statusMap.put("놀람",(double)diary.getDiarySurprise());
        statusMap.put("불안",(double)diary.getDiaryFear());
        statusMap.put("기쁨",(double)diary.getDiaryHappiness());

        return SingleAdviceResponseDto.builder()
                .sentence(analyze.getSentence())
                .emotion(emotionList)
                .adviceContent("null")
                .status(statusMap).build();
    }

    public AdviceResponseDto getAdviceByPeriod(Long memberIndex, AdviceRequestDto adviceRequestDto) {
        Advice advice = adviceRepository.findByMemberIndexAndPeriod(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate());
        return advice.toDto();
    }
}
