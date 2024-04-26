package com.ssafy.diary.domain.member.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
public class MemberInfoResponseDto {
    private String memberId;
    private String memberNickName;
    private String memberEmail;

    @Builder
    public MemberInfoResponseDto(String memberId, String memberNickName, String memberEmail) {
        this.memberId = memberId;
        this.memberNickName = memberNickName;
        this.memberEmail = memberEmail;
    }
}
