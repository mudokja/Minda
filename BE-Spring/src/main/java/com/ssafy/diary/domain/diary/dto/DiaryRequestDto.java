package com.ssafy.diary.domain.diary.dto;

import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import com.ssafy.diary.domain.diary.model.DiaryHashtag;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class DiaryRequestDto {

    private Long diaryIndex;

    private LocalDate diarySetDate;

    private String diaryTitle;

    private String diaryContent;

    private List<String> hashtagList;


    public Diary toEntity(List<Image> imageList, Long memberIndex) {
        return Diary.builder()
                .memberIndex(memberIndex)
                .diarySetDate(diarySetDate)
                .diaryTitle(diaryTitle)
                .diaryContent(diaryContent)
                .imageList(imageList)
                .build();
    }

    public DiaryHashtag hashtagToDocument(Long diaryIndex) {
        return DiaryHashtag.builder()
                .diaryIndex(diaryIndex)
                .hashtagList(hashtagList)
                .build();
    }

}
