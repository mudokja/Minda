package com.ssafy.diary.domain.diary.repository;

import com.ssafy.diary.domain.diary.entity.Diary;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DiaryRepository extends JpaRepository<Diary, Long> {
}
