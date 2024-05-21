package com.ssafy.diary.domain.refreshToken.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class RefreshTokenDto {
	private String memberIndex;
	private String refreshToken;
	private String expireTime;
	
}
