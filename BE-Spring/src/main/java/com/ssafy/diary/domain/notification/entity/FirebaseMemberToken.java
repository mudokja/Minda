package com.ssafy.diary.domain.notification.entity;

import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.global.constant.FireBasePlatform;
import com.ssafy.diary.global.entity.DateField;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(indexes = {@Index(name = "token_index_idx_member_index",columnList = "member_index")})
@Getter
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor
public class FirebaseMemberToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long firebaseTokenIndex;
    @Column(nullable = false,length = 512,unique = true)
    private String fireBaseToken;
    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private FireBasePlatform fireBasePlatform;
    @Embedded
    private DateField date=new DateField();

    @JoinColumn(name = "member_index",nullable = false)
    @ManyToOne(fetch = FetchType.LAZY,cascade = CascadeType.REMOVE)
    private Member member;
    @Builder
    public FirebaseMemberToken(String fireBaseToken, FireBasePlatform fireBasePlatform, Member member) {
        this.fireBaseToken = fireBaseToken;
        this.fireBasePlatform = fireBasePlatform;
        this.member = member;
    }
}
