package com.ssafy.diary.domain.advice.repository;

import com.ssafy.diary.domain.advice.entity.Advice;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdviceRepository extends JpaRepository<Advice, Long> {
}
