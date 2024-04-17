package com.ssafy.diary.domain.advice.entity;

import jakarta.persistence.*;
import lombok.Getter;

import java.time.LocalDateTime;

@Entity
@Getter
public class Advice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "advice_index")
    private Long adviceIndex;

//    @Column(name = "member_index")
//    private Long memberIndex;

    @Column(name = "start_date")
    private LocalDateTime startDate;

    @Column(name = "end_date")
    private LocalDateTime endDate;

    @Column(name = "advice_content")
    private String adviceContent;
}
