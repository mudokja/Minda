package com.ssafy.diary.domain.member.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
public class MemberInfoResponseDto {
    private String memberId;
    private String memberNickname;
    private String memberEmail;

    @Builder
    public MemberInfoResponseDto(String memberId, String memberNickname, String memberEmail) {
        this.memberId = memberId;
        this.memberNickname = memberNickname;
        this.memberEmail = memberEmail;
    }
}
