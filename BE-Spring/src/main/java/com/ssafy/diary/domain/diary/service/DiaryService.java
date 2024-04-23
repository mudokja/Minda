package com.ssafy.diary.domain.diary.service;

import com.ssafy.diary.domain.diary.dto.DiaryUpdateRequestDto;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.repository.DiaryRepository;
import com.ssafy.diary.global.exception.DiaryNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DiaryService {

    private final DiaryRepository diaryRepository;

    //일기 등록
    public void addDairy(Diary diary) {
        diaryRepository.save(diary);
    }

    //일기 조회
    public Diary getDiary(Long diaryIndex) {
        return diaryRepository.findById(diaryIndex)
                .orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryIndex));
    }

    //일기 수정
    @Transactional
    public void updateDiary(DiaryUpdateRequestDto diaryUpdateRequestDto) {
        Optional<Diary> optionalDiary = diaryRepository.findById(diaryUpdateRequestDto.getDiaryIndex());

        if (!optionalDiary.isPresent()) {
            throw new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryUpdateRequestDto.getDiaryIndex());
        } else {
            Diary diary = optionalDiary.get();
            diary.update(diaryUpdateRequestDto);
        }
    }

    //일기 삭제
    @Transactional
    public void removeDiary(Long diaryIndex) {
//        if (!diaryRepository.existsById(diaryIndex)) {
//            throw new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryIndex);
//        }
        diaryRepository.deleteById(diaryIndex);
    }

    //일기 목록 조회
    public List<Diary> getDiaryList(Long memberIndex){
        return diaryRepository.findByMemberIndex(memberIndex);
    }
}
