package com.ssafy.diary.domain.diary.model;

import jakarta.persistence.Id;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.List;

@Getter
@Setter
@Document(collection = "diary_hashtag")
public class DiaryHashtag {

    @Id
//    @Field(name="hashtag_index")
    private String hashtagIndex;

    @Field(name="member_index")
    private Long memberIndex;

    @Field(name="diary_index")
    private Long diaryIndex;

    @Field(name="hashtag_list")
    private List<String> hashtagList;

    @Builder
    public DiaryHashtag(String hashtagIndex, Long memberIndex, Long diaryIndex, List<String> hashtagList) {
        this.hashtagIndex = hashtagIndex;
        this.memberIndex = memberIndex;
        this.diaryIndex = diaryIndex;
        this.hashtagList = hashtagList;
    }

}
