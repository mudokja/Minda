package com.ssafy.diary.domain.member.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
public class MemberUpdatePasswordRequestDto {
    private String memberNewPassword;
    private String memberOldPassword;
    @Builder
    public MemberUpdatePasswordRequestDto(String memberNewPassword, String memberOldPassword) {
        this.memberNewPassword = memberNewPassword;
        this.memberOldPassword=  memberOldPassword;
    }
}
