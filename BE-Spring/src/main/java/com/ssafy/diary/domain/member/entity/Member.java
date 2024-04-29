package com.ssafy.diary.domain.member.entity;

import com.ssafy.diary.domain.advice.entity.Advice;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.global.entity.BaseEntity;
import jakarta.persistence.Entity;
import lombok.Getter;

import com.ssafy.diary.global.constant.AuthType;
import com.ssafy.diary.global.constant.Role;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.redis.core.index.Indexed;

import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@NoArgsConstructor
@Table(name = "member",indexes=@Index(columnList = "member_id"),
        uniqueConstraints = @UniqueConstraint(name = "UniqueIdAndPlatform", columnNames = { "member_id",
                "member_platform" }))
public class Member extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "member_index", nullable = false)
    private Long index;

    @Column(name = "member_id", nullable = false)
    private String id;

    @Setter
    @Column(name = "member_password")
    private String password;

    @Setter
    @Enumerated(EnumType.STRING)
    @Column(name = "member_role", nullable = false)
    private Role role = Role.USER;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "member_platform", nullable = false)
    private AuthType platform;

    @Setter
    @Column(name = "member_nickname")
    private String nickname;

    @Setter
    @Column(name = "member_email", nullable = false, unique = true)
    private String email;

    @Setter
    @Column(name = "member_profile_image")
    private String profileImage;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "member_index")
    private List<Diary> diaryList = new ArrayList<>();

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "member_index")
    private List<Advice> adviceList = new ArrayList<>();

    @Builder
    public Member(Long index, String id, String password, Role role, AuthType platform, String email, String nickname, String profileImage) {
        this.index = index;
        this.id = id;
        this.password = password;
        this.role = role;
        this.email = email;
        this.platform = platform;
        this.nickname = nickname;
        this.profileImage = profileImage;
    }
}
