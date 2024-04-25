package com.ssafy.diary.domain.analyze.controller;

import com.ssafy.diary.domain.analyze.entity.Analyze;
import com.ssafy.diary.domain.analyze.repository.AnalyzeRepository;
import com.ssafy.diary.domain.analyze.service.AnalyzeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("api/analyze")
public class AnalyzeController {
    private final AnalyzeService analyzeService;
    private final AnalyzeRepository analyzeRepository;
    @GetMapping("add")
    public String test(){
        analyzeService.addAnalyze();
        return "success";
    }
    @GetMapping("get")
    public String addTest(@RequestParam Long diaryIndex){
        return  analyzeService.getAnalyze(diaryIndex).toString();
    }

    @GetMapping("all")
    public List<Analyze> allTest(){
        return analyzeRepository.findAll();
    }
}
