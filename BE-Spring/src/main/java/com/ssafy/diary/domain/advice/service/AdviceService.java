package com.ssafy.diary.domain.advice.service;

import com.ssafy.diary.domain.advice.dto.AdviceRequestDto;
import com.ssafy.diary.domain.advice.dto.AdviceResponseDto;
import com.ssafy.diary.domain.advice.entity.Advice;
import com.ssafy.diary.domain.advice.repository.AdviceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdviceService {

    private final AdviceRepository adviceRepository;

    public AdviceResponseDto getAdviceByPeriod(Long memberIndex, AdviceRequestDto adviceRequestDto) {
        Advice advice = adviceRepository.findByMemberIndexAndPeriod(memberIndex, adviceRequestDto.getStartDate(), adviceRequestDto.getEndDate());

        return advice.toDto();
    }
}
