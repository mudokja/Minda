package com.ssafy.diary.domain.notification.entity;

import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.global.constant.FireBasePlatform;
import com.ssafy.diary.global.entity.BaseEntity;
import com.ssafy.diary.global.entity.DateEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(indexes = {@Index(name = "token_index_idx_member_index",columnList = "member_index")})
@Getter
@NoArgsConstructor
public class FirebaseMemberToken {
    @Id
    private Long firebaseTokenIndex;
    private String fireBaseToken;
    private FireBasePlatform fireBasePlatform;
    @Embedded
    private DateEntity date=new DateEntity();

    @JoinColumn(name = "member_index",nullable = false)
    @ManyToOne(fetch = FetchType.LAZY)
    private Member member;
}
