package com.ssafy.diary.domain.advice.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
public class SingleAdviceRequestDto {
    private LocalDate date;
}
