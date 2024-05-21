package com.ssafy.diary.domain.analyze.controller;

import com.ssafy.diary.domain.analyze.dto.AnalyzeRequestDto;
import com.ssafy.diary.domain.analyze.entity.Analyze;
import com.ssafy.diary.domain.analyze.repository.AnalyzeRepository;
import com.ssafy.diary.domain.analyze.service.AnalyzeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Analyze", description = "분석 테스트용 API")
@RestController
@RequiredArgsConstructor
@RequestMapping("api/analyze")
public class AnalyzeController {
    private final AnalyzeService analyzeService;
    private final AnalyzeRepository analyzeRepository;

    @Operation(summary = "분석 조회 테스트", description = "일기 하나(하루)에 대한 분석 조회")
    @GetMapping
    public ResponseEntity<String> getAnalyze(@RequestParam Long diaryIndex){
        return ResponseEntity.ok(analyzeService.getAnalyze(diaryIndex).toString());
    }

    @Operation(summary = "분석 요청 테스트", description = "일기 하나(하루)에 대한 분석 요청")
    @PostMapping
    public ResponseEntity<String> postAnalyze(@RequestBody AnalyzeRequestDto analyzeRequestDto) {
        return ResponseEntity.ok(analyzeService.addAnalyze(analyzeRequestDto).block());
    }

    @Operation(summary = "모든 분석 결과 리스트 조회", description = "모든 분석 결과 리스트 조회")
    @GetMapping("all")
    public List<Analyze> allTest(){
        return analyzeRepository.findAll();
    }
}
