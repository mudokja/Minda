package com.ssafy.diary.domain.email.entity;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.TimeToLive;
import org.springframework.data.redis.core.index.Indexed;

import java.time.LocalDateTime;

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
    @CreatedDate
//    @JsonSerialize(using = LocalDateTimeSerializer.class)
//    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    private LocalDateTime regDate;
    @TimeToLive
    private Long expireTime;

    @Builder
    public VerificationCode(String verificationId, String code, String email, Long expireTime, LocalDateTime regDate) {
        this.verificationId = verificationId;
        this.code = code;
        this.email = email;
        this.expireTime = expireTime;
        this.regDate = regDate;
    }
}
