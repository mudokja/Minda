package com.ssafy.diary.domain.diary.entity;


import com.ssafy.diary.domain.diary.dto.DiaryRequestDto;
import com.ssafy.diary.domain.diary.dto.DiaryResponseDto;
import com.ssafy.diary.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.cglib.core.Local;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@NoArgsConstructor
//@EntityListeners(AuditingEntityListener.class)
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

    @Column(name = "diary_content")
    private String diaryContent;

    @Setter
    @Column(name = "diary_happiness")
    private Long diaryHappiness;

    @Setter
    @Column(name = "diary_sadness")
    private Long diarySadness;

    @Setter
    @Column(name = "diary_fear")
    private Long diaryFear;

    @Setter
    @Column(name = "diary_anger")
    private Long diaryAnger;

//    @Column(name = "diary_disgust")
//    private Long diaryDisgust;

    @Setter
    @Column(name = "diary_surprise")
    private Long diarySurprise;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "diary_index")
    private List<Image> imageList = new ArrayList<>();

    @Builder
    public Diary (Long memberIndex, LocalDate diarySetDate, String diaryTitle, String diaryContent, Long diaryHappiness, Long diarySadness, Long diaryFear, Long diaryAnger, Long diarySurprise, List<Image> imageList){
        this.memberIndex = memberIndex;
        this.diarySetDate = diarySetDate;
        this.diaryTitle = diaryTitle;
        this.diaryContent = diaryContent;
        this.diaryHappiness = diaryHappiness;
        this.diarySadness = diarySadness;
        this.diaryFear = diaryFear;
        this.diaryAnger = diaryAnger;
//        this.diaryDisgust = diaryDisgust;
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
//                .diaryDisgust(diaryDisgust)
                .diarySurprise(diarySurprise)
                .imageList(imageList)
//                .hashtagList(hashtagList)
                .build();
    }

    public void update(DiaryRequestDto diaryUpdateRequestDto) {
        this.diaryTitle = diaryUpdateRequestDto.getDiaryTitle();
        this.diaryContent = diaryUpdateRequestDto.getDiaryContent();
//        this.diaryHappiness = diaryUpdateRequestDto.getDiaryHappiness();
//        this.diarySadness = diaryUpdateRequestDto.getDiarySadness();
//        this.diaryFear = diaryUpdateRequestDto.getDiaryFear();
//        this.diaryAnger = diaryUpdateRequestDto.getDiaryAnger();
//        this.diaryDisgust = diaryUpdateRequestDto.getDiaryDisgust();
//        this.diarySurprise = diaryUpdateRequestDto.getDiarySurprise();
    }

}
