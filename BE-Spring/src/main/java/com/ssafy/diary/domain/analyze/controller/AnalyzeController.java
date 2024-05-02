package com.ssafy.diary.domain.analyze.controller;

import com.ssafy.diary.domain.analyze.dto.AnalyzeRequestDto;
import com.ssafy.diary.domain.analyze.entity.Analyze;
import com.ssafy.diary.domain.analyze.repository.AnalyzeRepository;
import com.ssafy.diary.domain.analyze.service.AnalyzeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("api/analyze")
public class AnalyzeController {
    private final AnalyzeService analyzeService;
    private final AnalyzeRepository analyzeRepository;

    @GetMapping
    public ResponseEntity<String> getAnalyze(@RequestParam Long diaryIndex){
        return ResponseEntity.ok(analyzeService.getAnalyze(diaryIndex).toString());
    }

    @PostMapping
    public ResponseEntity<String> postAnalyze(@RequestBody AnalyzeRequestDto analyzeRequestDto) {
        return ResponseEntity.ok(analyzeService.addAnalyze(analyzeRequestDto).block());
    }


//    @GetMapping("add")
//    public String test(){
////        analyzeService.addAnalyze();
//        return "success";
//    }
//    @GetMapping("get")
//    public String addTest(@RequestParam Long diaryIndex){
//        return  analyzeService.getAnalyze(diaryIndex).toString();
//    }

//    @GetMapping("get")
//    public ResponseEntity<String> getTest(@RequestParam Long diaryIndex){
//        return  ResponseEntity.ok(analyzeService.getAnalyze(diaryIndex).toString());
//    }
//
//    @GetMapping("all")
//    public List<Analyze> allTest(){
//        return analyzeRepository.findAll();
//    }
}
