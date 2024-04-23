package com.ssafy.diary.domain.diary.entity;


import com.ssafy.diary.domain.diary.dto.DiaryUpdateRequestDto;
import com.ssafy.diary.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Generated;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
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

    public void update(DiaryUpdateRequestDto diaryUpdateRequestDto) {
        this.diaryTitle = diaryUpdateRequestDto.getDiaryTitle();
        this.diaryContent = diaryUpdateRequestDto.getDiaryContent();
        this.diaryHappiness = diaryUpdateRequestDto.getDiaryHappiness();
        this.diarySadness = diaryUpdateRequestDto.getDiarySadness();
        this.diaryFear = diaryUpdateRequestDto.getDiaryFear();
        this.diaryAnger = diaryUpdateRequestDto.getDiaryAnger();
        this.diaryDisgust = diaryUpdateRequestDto.getDiaryDisgust();
        this.diarySurprise = diaryUpdateRequestDto.getDiarySurprise();
        this.imageList = diaryUpdateRequestDto.getImageList();
    }

}
