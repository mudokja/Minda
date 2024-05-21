package com.ssafy.diary.domain.advice.repository;

import com.ssafy.diary.domain.advice.entity.Advice;
import com.ssafy.diary.domain.diary.entity.Diary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface AdviceRepository extends JpaRepository<Advice, Long> {

    @Query("SELECT a FROM Advice a WHERE a.memberIndex = :memberIndex AND a.startDate = :startDate AND a.endDate = :endDate")
    Optional<Advice> findByMemberIndexAndPeriod(@Param("memberIndex") Long memberIndex, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    @Query("SELECT a FROM Advice a WHERE a.memberIndex = :memberIndex AND a.startDate <= :startDate AND a.endDate >= :endDate")
    List<Advice> findByAllMemberIndexAndPeriod(@Param("memberIndex") Long memberIndex, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    @Query("SELECT a FROM Advice a WHERE a.memberIndex = :memberIndex AND ((a.startDate < :diarySetDate AND a.endDate > :diarySetDate) OR (a.startDate < :diarySetDate AND a.endDate >= :diarySetDate) OR (a.startDate <= :diarySetDate AND a.endDate > :diarySetDate))")
    List<Advice> findAdvicesByMemberIndexAndDate(
            @Param("memberIndex") Long memberIndex,
            @Param("diarySetDate") LocalDate diarySetDate
    );

    @Modifying
    @Query("DELETE FROM Advice a WHERE a.memberIndex = :memberIndex AND a.startDate = :startDate AND a.endDate = :endDate")
    void deleteByMemberIndexAndDate(Long memberIndex, @Param("startDate")LocalDate startDate, @Param("endDate")LocalDate endDate);

}
