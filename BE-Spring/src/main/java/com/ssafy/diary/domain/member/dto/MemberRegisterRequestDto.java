package com.ssafy.diary.domain.member.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class MemberRegisterRequestDto {
    private String id;
    private String password;
    private String nickname;
    private String email;
}