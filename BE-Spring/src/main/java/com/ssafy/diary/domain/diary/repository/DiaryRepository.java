package com.ssafy.diary.domain.diary.repository;

import com.ssafy.diary.domain.diary.entity.Diary;
import org.springframework.cglib.core.Local;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface DiaryRepository extends JpaRepository<Diary, Long> {
    List<Diary> findByMemberIndex(Long memberIndex);

    @Query("SELECT d FROM Diary d WHERE d.diarySetDate BETWEEN :startDate AND :endDate")
    List<Diary> findByDiarySetDate(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}
