package com.ssafy.diary.domain.analyze.service;

import com.ssafy.diary.domain.analyze.entity.Analyze;
import com.ssafy.diary.domain.analyze.repository.AnalyzeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AnalyzeService {
    private final AnalyzeRepository analyzeRepository;
    public Analyze getAnalyze(Long diaryIndex){
        return analyzeRepository.findByDiaryIndex(diaryIndex).orElse(null);
    }
    public void addAnalyze(){
        Analyze analyze = Analyze.builder().diaryIndex(11L).emotion(null).build();
        analyzeRepository.save(analyze);
    }
    public void updateAnalyze(){
    }
    public void removeAnalyze(){
    }
}
