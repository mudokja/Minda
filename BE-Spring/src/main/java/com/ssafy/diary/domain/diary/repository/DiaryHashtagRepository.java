package com.ssafy.diary.domain.diary.repository;

import com.ssafy.diary.domain.diary.model.DiaryHashtag;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface DiaryHashtagRepository extends MongoRepository<DiaryHashtag, String> {
    DiaryHashtag findByDiaryIndex(Long diaryIndex);

    void deleteByDiaryIndex(Long diaryIndex);
}
