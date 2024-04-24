package com.ssafy.diary.domain.diary.dto;

import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Getter
@Setter
public class DiaryRequestDto {

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

//    private List<MultipartFile> imageFileList;

    public Diary toEntity(List<Image> imageList) {
        return Diary.builder()
                .memberIndex(memberIndex)
                .diaryTitle(diaryTitle)
                .diaryContent(diaryContent)
                .diaryHappiness(diaryHappiness)
                .diarySadness(diarySadness)
                .diaryFear(diaryFear)
                .diaryAnger(diaryAnger)
                .diaryDisgust(diaryDisgust)
                .diarySurprise(diarySurprise)
                .imageList(imageList)
                .build();
    }

}
