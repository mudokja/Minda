package com.ssafy.diary.domain.diary.dto;

import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class DiaryResponseDto {

    private Long diaryIndex;

    private LocalDate diarySetDate;

    private String diaryTitle;

    private String diaryContent;

    private Double diaryHappiness;

    private Double diarySadness;

    private Double diaryFear;

    private Double diaryAnger;

    private Double diarySurprise;

    private List<Image> imageList;

    private List<String> hashtagList;

    @Builder
    public DiaryResponseDto(Long diaryIndex, LocalDate diarySetDate, String diaryTitle, String diaryContent, Double diaryHappiness, Double diarySadness, Double diaryFear, Double diaryAnger, Double diarySurprise, List<Image> imageList, List<String> hashtagList) {
        this.diaryIndex = diaryIndex;
        this.diarySetDate = diarySetDate;
        this.diaryTitle = diaryTitle;
        this.diaryContent = diaryContent;
        this.diaryHappiness = diaryHappiness;
        this.diarySadness = diarySadness;
        this.diaryFear = diaryFear;
        this.diaryAnger = diaryAnger;
        this.diarySurprise = diarySurprise;
        this.imageList = imageList;
        this.hashtagList = hashtagList;
    }
}
