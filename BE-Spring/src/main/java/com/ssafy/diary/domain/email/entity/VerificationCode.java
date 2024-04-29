package com.ssafy.diary.domain.email.entity;

import jakarta.persistence.Column;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;
import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.TimeToLive;
import org.springframework.data.redis.core.index.Indexed;

@Getter
@ToString
@RedisHash("verification_code")
public class VerificationCode {
    @Id
    @Column(nullable = false)
    private String verificationId;
    private String code;
    @Indexed
    private String email;
    @TimeToLive
    private Long expireTime;

    @Builder
    public VerificationCode(String verificationId, String code, String email, Long expireTime) {
        this.verificationId = verificationId;
        this.code = code;
        this.email = email;
        this.expireTime = expireTime;
    }
}
