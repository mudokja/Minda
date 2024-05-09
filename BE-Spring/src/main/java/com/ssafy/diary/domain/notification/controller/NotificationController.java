package com.ssafy.diary.domain.notification.controller;

import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.notification.dto.*;
import com.ssafy.diary.domain.notification.entity.FirebaseMemberToken;
import com.ssafy.diary.domain.notification.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notification")
@RequiredArgsConstructor
@Tag(name = "notification", description = "알림 API")
public class NotificationController {
    private final NotificationService notificationService;
    @Operation(summary = "유저 알림 보내기", description = "유저 기기를 대상으로 알림 전송")
    @PostMapping("/member")
    public ResponseEntity<KafkaNotificationMessageResponseDto> sendMemberNotification(@RequestBody KafkaMemberNotificationMessageRequestDto kafkaMemberNotificationMessageRequestDto){

        return ResponseEntity.ok().body(notificationService.sendKafkaFireBaseNotificationMessage(kafkaMemberNotificationMessageRequestDto));
    }
    @Operation(summary = "토큰 알림 보내기", description = "특정 기기를 대상으로 알림 전송")
    @PostMapping("/token")
    public ResponseEntity<KafkaNotificationMessageResponseDto> sendTokenNotification(@RequestBody KafkaTokenNotificationMessageRequestDto kafkaMemberNotificationMessageRequestDto){

        return ResponseEntity.ok().body(notificationService.sendKafkaFireBaseNotificationMessage(kafkaMemberNotificationMessageRequestDto));
    }
    @Operation(summary = "사용자 기기 토큰 제거", description = "사용자 기기토큰 삭제")
    @DeleteMapping
    public ResponseEntity<String> deleteFirebaseNotificationToken(@RequestParam String token) {
        notificationService.deleteFirebaseMemberToken(token);
        return ResponseEntity.ok("success");
    }
    @Operation(summary = "사용자 기기 토큰 등록", description = "사용자가 사용하는 기기토큰 등록")
    @PostMapping
    public ResponseEntity<String> registerFirebaseNotificationToken(@AuthenticationPrincipal PrincipalMember principal, @RequestBody FirebaseMemberTokenRequestDto firebaseMemberTokenRequestDto) {
        notificationService.addFirebaseMemberToken(firebaseMemberTokenRequestDto, principal.getIndex());
        return ResponseEntity.ok("success");
    }
}
