package com.ssafy.diary.domain.diary.dto;

import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Getter
@Setter
public class DiaryResponseDto {

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

    public DiaryResponseDto(Diary diary) {
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
}
