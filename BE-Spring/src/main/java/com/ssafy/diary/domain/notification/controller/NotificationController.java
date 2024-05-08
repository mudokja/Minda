package com.ssafy.diary.domain.notification.controller;

import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.notification.dto.*;
import com.ssafy.diary.domain.notification.entity.FirebaseMemberToken;
import com.ssafy.diary.domain.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notification")
@RequiredArgsConstructor
public class NotificationController {
    private final NotificationService notificationService;
    @PostMapping("/token")
    public ResponseEntity<KafkaNotificationMessageResponseDto> sendTokenNotification(@RequestBody KafkaMemberNotificationMessageRequestDto kafkaMemberNotificationMessageRequestDto){

        return ResponseEntity.ok().body(notificationService.sendKafkaFireBaseNotificationMessage(kafkaMemberNotificationMessageRequestDto));
    }
    @PostMapping("/member")
    public ResponseEntity<KafkaNotificationMessageResponseDto> sendMemberNotification(@RequestBody KafkaTokenNotificationMessageRequestDto kafkaMemberNotificationMessageRequestDto){

        return ResponseEntity.ok().body(notificationService.sendKafkaFireBaseNotificationMessage(kafkaMemberNotificationMessageRequestDto));
    }

    @PostMapping
    public ResponseEntity<String> registerFirebaseNotificationToken(@AuthenticationPrincipal PrincipalMember principal, @RequestBody FirebaseMemberTokenRegisterDto firebaseMemberTokenRegisterDto) {
        notificationService.addFirebaseMemberToken(FirebaseMemberToken.builder()
                .fireBaseToken(firebaseMemberTokenRegisterDto.getToken())
                .fireBasePlatform(firebaseMemberTokenRegisterDto.getPlatform())
                .memberIndex(principal.getIndex())
                .build());
        return ResponseEntity.ok("success");
    }
}
