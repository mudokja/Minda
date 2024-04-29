package com.ssafy.diary.domain.email.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.ssafy.diary.domain.email.dto.CodeVerificationRequestDto;
import com.ssafy.diary.domain.email.dto.CodeVerificationResponseDto;
import com.ssafy.diary.domain.email.dto.EmailAuthRequestDto;
import com.ssafy.diary.domain.email.dto.EmailAuthResponseDto;
import com.ssafy.diary.domain.email.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/email")
public class EmailController {
    private final EmailService emailService;
    @PostMapping("/verification")
    public ResponseEntity<CodeVerificationResponseDto> sendVerificationEmail(@RequestBody CodeVerificationRequestDto verificationRequestDto) throws JsonProcessingException {
        return ResponseEntity.ok().body(emailService.sendKafkaEmailAuthMessage(verificationRequestDto));
    }

    @PostMapping("/auth")
    public ResponseEntity<EmailAuthResponseDto> sendVerificationEmail(@RequestBody EmailAuthRequestDto emailAuthRequestDto){
        EmailAuthResponseDto result = emailService.checkAuthEmail(emailAuthRequestDto);
        if(result != null){
        return ResponseEntity.ok().body(result);

        }
        return ResponseEntity.badRequest().build();
    }
}
