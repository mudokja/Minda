package com.ssafy.diary.domain.diary.dto;

import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class DiaryResponseDto {

    private Long diaryIndex;

    private LocalDateTime diarySetDate;

    private String diaryTitle;

    private String diaryContent;

    private Long diaryHappiness;

    private Long diarySadness;

    private Long diaryFear;

    private Long diaryAnger;

//    private Long diaryDisgust;

    private Long diarySurprise;

    private List<Image> imageList;

    private List<String> hashtagList;

    @Builder
    public DiaryResponseDto(Long diaryIndex, LocalDateTime diarySetDate, String diaryTitle, String diaryContent, Long diaryHappiness, Long diarySadness, Long diaryFear, Long diaryAnger, Long diarySurprise, List<Image> imageList, List<String> hashtagList) {
        this.diaryIndex = diaryIndex;
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
        this.hashtagList = hashtagList;
    }
}
