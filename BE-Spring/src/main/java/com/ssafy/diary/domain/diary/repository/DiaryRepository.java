package com.ssafy.diary.domain.diary.repository;

import com.ssafy.diary.domain.diary.entity.Diary;
import org.springframework.cglib.core.Local;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface DiaryRepository extends JpaRepository<Diary, Long> {
    List<Diary> findByMemberIndex(Long memberIndex);

    List<Diary> findByMemberIndexAndDiaryTitleContaining(Long memberIndex, String keyword);

    Optional<Diary> findByMemberIndexAndDiarySetDate(@Param("memberIndex") Long MemberIndex, @Param("diarySetDate") LocalDate diarySetDate);
    @Query("SELECT d FROM Diary d WHERE d.memberIndex = :memberIndex AND d.diarySetDate BETWEEN :startDate AND :endDate")
    List<Diary> findByMemberIndexAndDiarySetDate(@Param("memberIndex") Long MemberIndex, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

}
