package com.ssafy.diary.domain.diary.repository;

import com.ssafy.diary.domain.diary.entity.Image;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import javax.swing.text.html.Option;
import java.util.Optional;

@Repository
public interface ImageRepository extends JpaRepository<Image, Long> {
    Boolean existsByDiaryIndex(Long diaryIndex);
}
