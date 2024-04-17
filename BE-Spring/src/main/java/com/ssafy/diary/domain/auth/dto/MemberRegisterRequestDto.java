package com.ssafy.diary.domain.auth.dto;

import lombok.Data;

@Data
public class MemberRegisterRequestDto {
    private String id;
    private String password;
    private String nickname;
}