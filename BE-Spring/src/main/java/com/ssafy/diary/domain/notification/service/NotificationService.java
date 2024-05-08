package com.ssafy.diary.domain.notification.service;

import com.google.firebase.messaging.FirebaseMessagingException;
import com.ssafy.diary.domain.notification.dto.*;
import com.ssafy.diary.domain.notification.entity.FirebaseMemberToken;
import com.ssafy.diary.domain.notification.repository.FirebaseMemberTokenRepository;
import com.ssafy.diary.global.util.FCMUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class NotificationService {
    private final static String notificationMemberTopic="diary.notification.member";
    private final static String notificationTokenTopic="diary.notification.token";
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final FirebaseMemberTokenRepository firebaseMemberTokenRepository;

    public void addFirebaseMemberToken(FirebaseMemberToken firebaseMemberToken) {
        firebaseMemberTokenRepository.save(firebaseMemberToken);
    }

    public KafkaNotificationMessageResponseDto sendKafkaFireBaseNotificationMessage(KafkaMemberNotificationMessageRequestDto notificationMessageRequestDto) {

        kafkaTemplate.send(notificationMemberTopic, notificationMessageRequestDto);
        return KafkaNotificationMessageResponseDto.builder()

                .resultMessage("성공")
                .build();
    }
    public KafkaNotificationMessageResponseDto sendKafkaFireBaseNotificationMessage(KafkaTokenNotificationMessageRequestDto notificationMessageRequestDto) {

        kafkaTemplate.send(notificationMemberTopic, notificationMessageRequestDto);
        return KafkaNotificationMessageResponseDto.builder()
                .resultMessage("성공")
                .build();
    }

    @KafkaListener(topics = notificationMemberTopic, groupId = "diary_consumer_01"
            , properties = {"spring.json.value.default.type:com.ssafy.diary.domain.notification.dto.KafkaMemberNotificationMessageRequestDto"}
            )
    public void sendFirebaseMemberNotificationMessage(KafkaMemberNotificationMessageRequestDto message) throws FirebaseMessagingException {
        log.debug("알림 메시지 수신 : {}",message.toString());
        List<String> sendList=firebaseMemberTokenRepository.findAllByMemberIndex(message.getMemberIndex()).stream().map(FirebaseMemberToken::getFireBaseToken).toList();

        FCMUtil.sendAllNotificationMessage(message.getTitle(),message.getBody(),sendList );
    }
    @KafkaListener(topics = notificationTokenTopic, groupId = "diary_consumer_01"
            , properties = {"spring.json.value.default.type:com.ssafy.diary.domain.notification.dto.KafkaTokenNotificationMessageRequestDto"}
    )
    public void sendFirebaseTokenNotificationMessage(KafkaTokenNotificationMessageRequestDto message) throws FirebaseMessagingException {
        log.debug("알림 메시지 수신 : {}",message.toString());

        FCMUtil.sendNotificationMessage(message.getTitle(),message.getBody(),message.getToken() );
    }
}
