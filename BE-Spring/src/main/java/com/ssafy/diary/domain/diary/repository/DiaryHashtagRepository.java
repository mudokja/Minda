package com.ssafy.diary.domain.diary.repository;

import com.ssafy.diary.domain.diary.model.DiaryHashtag;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface DiaryHashtagRepository extends MongoRepository<DiaryHashtag, String> {
    DiaryHashtag findByDiaryIndex(Long diaryIndex);

    void deleteByDiaryIndex(Long diaryIndex);

    @Query("{ 'memberIndex': ?0, 'hashtagList': { $regex: ?1, $options: 'i' } }")
    List<DiaryHashtag> findByMemberIndexAndHashtagListContaining(Long memberIndex, String keyword);
}
