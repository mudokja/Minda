package com.ssafy.diary.domain.member.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
public class MemberModifyRequestDto {
    private String memberNickName;
    private String memberEmail;
    private String memberNewPassword;
    private String memberOldPassword;
    @Builder
    public MemberModifyRequestDto(String memberNickName, String memberEmail, String memberNewPassword, String memberOldPassword) {
        this.memberNickName = memberNickName;
        this.memberEmail = memberEmail;
        this.memberNewPassword = memberNewPassword;
        this.memberOldPassword=  memberOldPassword;
    }
}
