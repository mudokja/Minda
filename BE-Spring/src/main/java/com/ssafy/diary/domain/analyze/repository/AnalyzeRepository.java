package com.ssafy.diary.domain.analyze.repository;

import com.ssafy.diary.domain.advice.entity.Advice;
import com.ssafy.diary.domain.analyze.entity.Analyze;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import javax.swing.text.html.Option;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface AnalyzeRepository extends MongoRepository<Analyze,Long> {
    Optional<Analyze> findByDiaryIndex(Long diaryIndex);
    void deleteByDiaryIndex(Long diaryIndex);
    List<Analyze> findByDiaryIndexIn(List<Long> diaryIndexes);
    @Query("{ 'startDate' : { '$gte': ?0 }, 'endDate' : { '$lte': ?1 } }")
    List<Analyze> findByAllStartDateAndEndDateBetween(LocalDate startDate, LocalDate endDate);
}
