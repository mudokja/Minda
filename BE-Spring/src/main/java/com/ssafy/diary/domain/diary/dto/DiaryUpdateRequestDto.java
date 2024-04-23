package com.ssafy.diary.domain.diary.dto;

import com.ssafy.diary.domain.diary.entity.Image;
import jakarta.persistence.*;
import lombok.Getter;
import org.springframework.data.annotation.CreatedDate;

import java.time.LocalDateTime;
import java.util.List;

@Getter
public class DiaryUpdateRequestDto {

    private Long diaryIndex;

    private Long memberIndex;

//    private LocalDateTime diarySetDate;

    private String diaryTitle;

    private String diaryContent;

    private Long diaryHappiness;

    private Long diarySadness;

    private Long diaryFear;

    private Long diaryAnger;

    private Long diaryDisgust;

    private Long diarySurprise;

    private List<Image> imageList;
}
