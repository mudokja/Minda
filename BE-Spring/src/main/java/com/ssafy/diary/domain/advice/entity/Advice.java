package com.ssafy.diary.domain.advice.entity;

import com.ssafy.diary.domain.advice.dto.AdviceResponseDto;
import com.ssafy.diary.domain.diary.entity.Image;
import com.ssafy.diary.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.awt.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

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
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column(name = "advice_content", columnDefinition = "TEXT")
    private String adviceContent;

    @Column(name = "image_link")
    private String imageLink;

    @Column(name= "advice_comment")
    private String adviceComment;

    @Builder
    public Advice (Long memberIndex, LocalDate startDate, LocalDate endDate, String adviceContent,String adviceComment){
        this.memberIndex = memberIndex;
        this.startDate =startDate;
        this.endDate = endDate;
        this.adviceContent = adviceContent;
        this.adviceComment = adviceComment;
    }

//    public AdviceResponseDto toDto() {
//        return AdviceResponseDto.builder()
//                .adviceIndex(adviceIndex)
//                .adviceContent(adviceContent)
//                .startDate(startDate)
//                .endDate(endDate)
//                .build();
//    }
}
