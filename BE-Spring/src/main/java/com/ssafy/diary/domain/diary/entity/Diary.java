package com.ssafy.diary.domain.diary.entity;


import com.ssafy.diary.domain.diary.dto.DiaryRequestDto;
import com.ssafy.diary.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Diary extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long diaryIndex;

    @Setter
    @Column(name = "member_index")
    private Long memberIndex;

//    @CreatedDate
//    @Column(name = "diary_set_date")
//    private LocalDateTime diarySetDate;

    @Column(name = "diary_title")
    private String diaryTitle;

    @Column(name = "diary_content")
    private String diaryContent;

    @Column(name = "diary_happiness")
    private Long diaryHappiness;

    @Column(name = "diary_sadness")
    private Long diarySadness;

    @Column(name = "diary_fear")
    private Long diaryFear;

    @Column(name = "diary_anger")
    private Long diaryAnger;

    @Column(name = "diary_disgust")
    private Long diaryDisgust;

    @Column(name = "diary_surprise")
    private Long diarySurprise;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "diary_index")
    private List<Image> imageList = new ArrayList<>();

    @Builder
    public Diary (Long memberIndex, String diaryTitle, String diaryContent, Long diaryHappiness, Long diarySadness, Long diaryFear, Long diaryAnger, Long diaryDisgust, Long diarySurprise, List<Image> imageList){
        this.memberIndex = memberIndex;
        this.diaryTitle = diaryTitle;
        this.diaryContent = diaryContent;
        this.diaryHappiness = diaryHappiness;
        this.diarySadness = diarySadness;
        this.diaryFear = diaryFear;
        this.diaryAnger = diaryAnger;
        this.diaryDisgust = diaryDisgust;
        this.diarySurprise = diarySurprise;
        this.imageList = imageList;
    }

    public void update(DiaryRequestDto diaryUpdateRequestDto, List<Image> imageList) {
        this.diaryTitle = diaryUpdateRequestDto.getDiaryTitle();
        this.diaryContent = diaryUpdateRequestDto.getDiaryContent();
        this.diaryHappiness = diaryUpdateRequestDto.getDiaryHappiness();
        this.diarySadness = diaryUpdateRequestDto.getDiarySadness();
        this.diaryFear = diaryUpdateRequestDto.getDiaryFear();
        this.diaryAnger = diaryUpdateRequestDto.getDiaryAnger();
        this.diaryDisgust = diaryUpdateRequestDto.getDiaryDisgust();
        this.diarySurprise = diaryUpdateRequestDto.getDiarySurprise();
        this.imageList = imageList;
    }

}
