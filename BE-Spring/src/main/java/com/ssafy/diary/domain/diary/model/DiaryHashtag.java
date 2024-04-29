package com.ssafy.diary.domain.diary.model;

import jakarta.persistence.Id;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;

@Getter
@Setter
@Document(collection = "diary_hashtag")
public class DiaryHashtag {

    @Id
    private String hashtagIndex;

    private Long diaryIndex;

    private List<String> hashtagList;

    @Builder
    public DiaryHashtag(String hashtagIndex, Long diaryIndex, List<String> hashtagList) {
        this.hashtagIndex = hashtagIndex;
        this.diaryIndex = diaryIndex;
        this.hashtagList = hashtagList;
    }
}
