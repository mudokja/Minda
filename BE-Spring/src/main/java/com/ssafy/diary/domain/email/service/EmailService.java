package com.ssafy.diary.domain.email.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.diary.domain.email.dto.*;
import com.ssafy.diary.domain.email.entity.VerificationCode;
import com.ssafy.diary.domain.email.repository.VerificationRepository;
import com.ssafy.diary.global.util.EmailUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.common.protocol.Message;
import org.apache.kafka.common.protocol.types.Field;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@Slf4j
@RequiredArgsConstructor
public class EmailService {
    private final String verificationTopics = "diary.email.verification";
    private final VerificationRepository verificationRepository;
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final EmailUtil emailUtil;
    private final ObjectMapper objectMapper;
    public CodeVerificationResponseDto sendKafkaEmailAuthMessage(CodeVerificationRequestDto verificationRequestDto) throws JsonProcessingException {
        String uuid = UUID.randomUUID().toString();
        String code = EmailUtil.generateCode();
        verificationRepository.save(VerificationCode.builder()
                .verificationId(uuid)
                .code(code)
                .expireTime(60L*5+5)
                .build()
        );
        kafkaTemplate.send(verificationTopics, objectMapper.writeValueAsString(KafkaEmailAuthDto.builder()
                .verificationId(uuid)
                .email(verificationRequestDto.getEmail())
                .code(code)
                .build()));
        return CodeVerificationResponseDto.builder()
                .verificationId(uuid)
                .build();
    }

//    @KafkaListener(topics = verificationTopics, groupId = "diary_consumer_01")
//    public void sendAuthEmail(Message message) throws JsonProcessingException {
//        log.debug("이메일 메시지 수신 : {}",message.toString());
//        KafkaEmailAuthDto kafkaEmailAuthDto =objectMapper.readValue(message.toString(),KafkaEmailAuthDto.class);
//        emailUtil.sendMail(kafkaEmailAuthDto.getEmail(),"[Mirror Diary]이메일 인증 메일입니다.", "인증번호 : "+kafkaEmailAuthDto.getCode());
//    }

    public EmailAuthResponseDto checkAuthEmail(EmailAuthRequestDto emailAuthRequestDto){
        VerificationCode verificationCode =verificationRepository.findById(emailAuthRequestDto.getVerificationId())
                .orElseThrow(()->new RuntimeException("email auth failed"));

        return EmailAuthResponseDto.builder()
                .authTime(LocalDateTime.now())
                .email(verificationCode.getEmail())
                .build();
    }
}
