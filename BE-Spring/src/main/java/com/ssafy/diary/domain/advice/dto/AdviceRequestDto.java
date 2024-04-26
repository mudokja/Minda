package com.ssafy.diary.domain.advice.dto;

import jakarta.persistence.Column;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class AdviceRequestDto {

    private LocalDateTime startDate;

    private LocalDateTime endDate;
}
