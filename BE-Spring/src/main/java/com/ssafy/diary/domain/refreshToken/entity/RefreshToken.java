package com.ssafy.diary.domain.refreshToken.entity;


import com.ssafy.diary.global.constant.AuthType;
import com.ssafy.diary.global.constant.Role;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.TimeToLive;
import org.springframework.data.redis.core.index.Indexed;

import java.time.LocalDateTime;

@Getter
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor
@RedisHash("refresh_token")
@ToString
public class RefreshToken {
    @Id
    String refreshToken;
    @Indexed
    Long memberIndex;
    @Enumerated(EnumType.STRING)
    Role role;
    @Enumerated(EnumType.STRING)
    AuthType platform;
    @TimeToLive
    Long expireTime;
    @CreatedDate
    LocalDateTime regDate;

    @Builder
    public RefreshToken(String refreshToken, LocalDateTime regDate, Long expireTime, AuthType platform, Role role, Long memberIndex) {
        this.refreshToken = refreshToken;
        this.regDate = regDate;
        this.expireTime = expireTime;
        this.platform = platform;
        this.role = role;
        this.memberIndex = memberIndex;
    }
}