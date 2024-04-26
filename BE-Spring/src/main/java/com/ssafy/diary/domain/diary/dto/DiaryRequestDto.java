package com.ssafy.diary.domain.diary.dto;

import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class DiaryRequestDto {

    private Long diaryIndex;

//    private Long memberIndex;

    private LocalDateTime diarySetDate;

    private String diaryTitle;

    private String diaryContent;


    public Diary toEntity(List<Image> imageList, Long memberIndex) {
        return Diary.builder()
                .memberIndex(memberIndex)
                .diarySetDate(diarySetDate)
                .diaryTitle(diaryTitle)
                .diaryContent(diaryContent)
                .imageList(imageList)
                .build();
    }

}
