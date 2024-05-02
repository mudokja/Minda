package com.ssafy.diary.domain.advice.controller;

import com.amazonaws.Response;
import com.ssafy.diary.domain.advice.dto.AdviceRequestDto;
import com.ssafy.diary.domain.advice.dto.AdviceResponseDto;
import com.ssafy.diary.domain.advice.dto.SingleAdviceRequestDto;
import com.ssafy.diary.domain.advice.dto.SingleAdviceResponseDto;
import com.ssafy.diary.domain.advice.service.AdviceService;
import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/advice")
@RequiredArgsConstructor
public class AdviceController {

    private final AdviceService adviceService;


    @GetMapping("single")
    public ResponseEntity<SingleAdviceResponseDto> getAdvice(@ModelAttribute SingleAdviceRequestDto singleAdviceRequestDto, @AuthenticationPrincipal PrincipalMember principalMember){
        Long memberIndex = principalMember.getIndex();
        return ResponseEntity.ok(adviceService.getAdvice(memberIndex,singleAdviceRequestDto));
    }

    @GetMapping
    //특정 기간의 조언 요청
    public ResponseEntity<AdviceResponseDto> getAdviceByPeriod(@ModelAttribute AdviceRequestDto adviceRequestDto, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        AdviceResponseDto advice = adviceService.getAdviceByPeriod(memberIndex, adviceRequestDto);
        return ResponseEntity.ok(advice);
    }

}
