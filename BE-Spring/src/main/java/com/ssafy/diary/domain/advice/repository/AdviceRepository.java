package com.ssafy.diary.domain.advice.repository;

import com.ssafy.diary.domain.advice.entity.Advice;
import com.ssafy.diary.domain.diary.entity.Diary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public interface AdviceRepository extends JpaRepository<Advice, Long> {

    @Query("SELECT a FROM Advice a WHERE a.memberIndex = :memberIndex AND a.startDate = :startDate AND a.endDate = :endDate")
    Advice findByMemberIndexAndPeriod(@Param("memberIndex") Long memberIndex, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
}
