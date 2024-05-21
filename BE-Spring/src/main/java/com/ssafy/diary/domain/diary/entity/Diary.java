package com.ssafy.diary.domain.diary.entity;


import com.ssafy.diary.domain.diary.dto.DiaryUpdateRequestDto;
import com.ssafy.diary.domain.diary.dto.DiaryResponseDto;
import com.ssafy.diary.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@NoArgsConstructor
public class Diary extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long diaryIndex;

    @Setter
    @Column(name = "member_index")
    private Long memberIndex;

    @Column(name = "diary_set_date")
    private LocalDate diarySetDate;

    @Column(name = "diary_title")
    private String diaryTitle;

    @Column(name = "diary_content", columnDefinition = "TEXT")
    private String diaryContent;

    @Setter
    @Column(name = "diary_happiness")
    private Double diaryHappiness;

    @Setter
    @Column(name = "diary_sadness")
    private Double diarySadness;

    @Setter
    @Column(name = "diary_fear")
    private Double diaryFear;

    @Setter
    @Column(name = "diary_anger")
    private Double diaryAnger;

    @Setter
    @Column(name = "diary_surprise")
    private Double diarySurprise;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "diary_index")
    private List<Image> imageList = new ArrayList<>();

    @Builder
    public Diary (Long memberIndex, LocalDate diarySetDate, String diaryTitle, String diaryContent, Double diaryHappiness, Double diarySadness, Double diaryFear, Double diaryAnger, Double diarySurprise, List<Image> imageList){
        this.memberIndex = memberIndex;
        this.diarySetDate = diarySetDate;
        this.diaryTitle = diaryTitle;
        this.diaryContent = diaryContent;
        this.diaryHappiness = diaryHappiness;
        this.diarySadness = diarySadness;
        this.diaryFear = diaryFear;
        this.diaryAnger = diaryAnger;
        this.diarySurprise = diarySurprise;
        this.imageList = imageList;
    }

    public DiaryResponseDto toDto() {
        return DiaryResponseDto.builder()
                .diaryIndex(diaryIndex)
                .diarySetDate(diarySetDate)
                .diaryTitle(diaryTitle)
                .diaryContent(diaryContent)
                .diaryHappiness(diaryHappiness)
                .diarySadness(diarySadness)
                .diaryFear(diaryFear)
                .diaryAnger(diaryAnger)
                .diarySurprise(diarySurprise)
                .imageList(imageList)
                .build();
    }

    public void update(DiaryUpdateRequestDto diaryUpdateRequestDto) {
        this.diaryTitle = diaryUpdateRequestDto.getDiaryTitle();
        this.diaryContent = diaryUpdateRequestDto.getDiaryContent();
    }

}
