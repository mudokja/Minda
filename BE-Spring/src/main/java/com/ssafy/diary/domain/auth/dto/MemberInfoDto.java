package com.ssafy.diary.domain.auth.dto;

import com.ssafy.diary.global.constant.AuthType;
import com.ssafy.diary.global.constant.Role;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MemberInfoDto {
    private Long index;
    private String id;
    private Role role;
    private AuthType platform;
    private String nickname;
    private String email;
    private String profileImage;
    @Builder
    public MemberInfoDto(Long index, String id, Role role, AuthType platform, String nickname, String email, String profileImage) {
        this.index = index;
        this.id = id;
        this.role = role;
        this.platform = platform;
        this.nickname = nickname;
        this.email = email;
        this.profileImage = profileImage;
    }
}
