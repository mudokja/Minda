package com.ssafy.diary.domain.email.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.ssafy.diary.domain.email.dto.*;
import com.ssafy.diary.domain.email.entity.VerificationCode;
import com.ssafy.diary.domain.email.repository.VerificationRepository;
import com.ssafy.diary.global.util.EmailUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

@Service
@Slf4j
@RequiredArgsConstructor
public class EmailService {
    private final String verificationTopics = "diary.email.verification";
    private final VerificationRepository verificationRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final EmailUtil emailUtil;
    public CodeVerificationResponseDto sendKafkaEmailAuthMessage(CodeVerificationRequestDto verificationRequestDto) throws JsonProcessingException {
        String uuid = UUID.randomUUID().toString();
        String code = EmailUtil.generateCode();
        verificationRepository.save(VerificationCode.builder()
                .verificationId(uuid)
                .code(code)
                .email(verificationRequestDto.getEmail())
                .expireTime(60L*5+5)
                .build()
        );
        kafkaTemplate.send(verificationTopics, KafkaEmailAuthDto.builder()
                .verificationId(uuid)
                .email(verificationRequestDto.getEmail())
                .code(code)
                .build());
        return CodeVerificationResponseDto.builder()
                .verificationId(uuid)
                .build();
    }

    @KafkaListener(topics = verificationTopics, groupId = "diary_consumer_01", properties = {"spring.json.value.default.type:com.ssafy.diary.domain.email.dto.KafkaEmailAuthDto"})
    public void sendAuthEmail(KafkaEmailAuthDto message) throws JsonProcessingException {
        log.debug("이메일 메시지 수신 : {}",message.toString());
        emailUtil.sendMail(message.getEmail(),"[Mirror Diary]이메일 인증 메일입니다.", "인증번호 : "+ message.getCode());
    }

    public EmailAuthResponseDto checkAuthEmail(EmailAuthRequestDto emailAuthRequestDto){
        VerificationCode verificationCode =verificationRepository.findById(emailAuthRequestDto.getVerificationId())
                .orElse(null);
        if(Objects.requireNonNull(verificationCode).getCode().equals(emailAuthRequestDto.getCode())) {
            return EmailAuthResponseDto.builder()
                    .resultMessage("success")
                    .authTime(LocalDateTime.now())
                    .email(verificationCode.getEmail())
                    .build();
        }
            return null;

    }
    public List<VerificationCode> getVerificationCodeListByEmail(String email){
        return verificationRepository.findByEmail(email);
    }
}
