package com.ssafy.diary.domain.advice.controller;

import com.amazonaws.Response;
import com.ssafy.diary.domain.advice.dto.AdviceRequestDto;
import com.ssafy.diary.domain.advice.dto.AdviceResponseDto;
import com.ssafy.diary.domain.advice.dto.SingleAdviceRequestDto;
import com.ssafy.diary.domain.advice.dto.SingleAdviceResponseDto;
import com.ssafy.diary.domain.advice.service.AdviceService;
import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Advice", description = "조언 API")
@RestController
@RequestMapping("/api/advice")
@RequiredArgsConstructor
public class AdviceController {

    private final AdviceService adviceService;

    @Operation(summary = "분석 조회(일별)", description = "일기 하나(하루)에 대한 분석")
    @GetMapping("single")
    public ResponseEntity<SingleAdviceResponseDto> getAdvice(@ModelAttribute SingleAdviceRequestDto singleAdviceRequestDto, @AuthenticationPrincipal PrincipalMember principalMember){
        Long memberIndex = principalMember.getIndex();
        return ResponseEntity.ok(adviceService.getAdvice(memberIndex,singleAdviceRequestDto));
    }

    @Operation(summary = "분석 조회(특정 기간)", description = "특정 기간(ex. 최근 일주일)에 대한 분석 조회")
    @GetMapping
    //특정 기간의 조언 요청
    public ResponseEntity<AdviceResponseDto> getAdviceByPeriod(@ModelAttribute AdviceRequestDto adviceRequestDto, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        AdviceResponseDto advice = adviceService.getAdviceByPeriod(memberIndex, adviceRequestDto);
        return ResponseEntity.ok(advice);
    }

    @GetMapping("test")
    public String test(){
        String response = adviceService.getWordcloudByPeriod(2L,LocalDate.parse("2024-05-01"),LocalDate.parse("2024-05-14"));
        return response;
    }
}
