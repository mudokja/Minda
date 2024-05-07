package com.ssafy.diary.domain.email.controller;

import com.amazonaws.util.StringUtils;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.ssafy.diary.domain.email.dto.CodeVerificationRequestDto;
import com.ssafy.diary.domain.email.dto.CodeVerificationResponseDto;
import com.ssafy.diary.domain.email.dto.EmailAuthRequestDto;
import com.ssafy.diary.domain.email.dto.EmailAuthResponseDto;
import com.ssafy.diary.domain.email.service.EmailService;
import com.ssafy.diary.global.exception.EmailException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Email", description = "이메일 API")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/email")
public class EmailController {
    private final EmailService emailService;

    @Operation(summary = "이메일 인증 요청")
    @PostMapping("/verification")
    public ResponseEntity<CodeVerificationResponseDto> sendVerificationEmail(@RequestBody CodeVerificationRequestDto verificationRequestDto) throws JsonProcessingException {
        if(StringUtils.isNullOrEmpty(verificationRequestDto.getEmail()))
            throw new EmailException.EmailNotValidEmail("Not valid email");
        if(!emailService.getVerificationCodeListByEmail(verificationRequestDto.getEmail()).isEmpty())
            throw new EmailException.EmailVerificationRequestTooMany("request Too many");
        return ResponseEntity.ok().body(emailService.sendKafkaEmailAuthMessage(verificationRequestDto));
    }

    @Operation(summary = "이메일 인증 코드 검사")
    @PostMapping("/auth")
    public ResponseEntity<EmailAuthResponseDto> sendVerificationEmail(@RequestBody EmailAuthRequestDto emailAuthRequestDto){
        EmailAuthResponseDto result = emailService.checkAuthEmail(emailAuthRequestDto);
        if(result != null){
        return ResponseEntity.ok().body(result);

        }
        return ResponseEntity.badRequest().build();
    }
}
