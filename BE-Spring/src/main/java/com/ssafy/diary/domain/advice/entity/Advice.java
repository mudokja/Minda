package com.ssafy.diary.domain.advice.entity;

import com.ssafy.diary.domain.advice.dto.AdviceResponseDto;
import com.ssafy.diary.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Getter
@NoArgsConstructor
public class Advice extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "advice_index")
    private Long adviceIndex;

    @Column(name = "member_index")
    private Long memberIndex;

    @Column(name = "start_date")
    private LocalDateTime startDate;

    @Column(name = "end_date")
    private LocalDateTime endDate;

    @Column(name = "advice_content")
    private String adviceContent;

//    public AdviceResponseDto toDto() {
//        return AdviceResponseDto.builder()
//                .adviceIndex(adviceIndex)
//                .adviceContent(adviceContent)
//                .startDate(startDate)
//                .endDate(endDate)
//                .build();
//    }
}
