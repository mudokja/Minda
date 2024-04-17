package com.ssafy.diary.domain.auth.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class LocalLoginRequestDto {
	private String id;
	private String password;
}
