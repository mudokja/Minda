package com.ssafy.diary.domain.member.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

@Getter
public class MemberInfoUpdateRequestDto {
    @Schema(nullable = true)
    private String memberNickname;
    @Schema(nullable = true)
    private String memberEmail;
    @Builder
    public MemberInfoUpdateRequestDto(String memberNickname, String memberEmail) {
        this.memberNickname = memberNickname;
        this.memberEmail = memberEmail;
    }
}
