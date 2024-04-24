package com.ssafy.diary.domain.diary.service;

import com.ssafy.diary.domain.diary.dto.DiaryRequestDto;
import com.ssafy.diary.domain.diary.dto.DiaryResponseDto;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import com.ssafy.diary.domain.diary.repository.DiaryRepository;
import com.ssafy.diary.domain.s3.service.S3Service;
import com.ssafy.diary.global.exception.DiaryNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DiaryService {

    private final DiaryRepository diaryRepository;
    private final S3Service s3Service;

    //일기 등록
    public void addDairy(DiaryRequestDto diaryAddRequestDto) {
        List<Image> imageList = saveAndGetImageList(diaryAddRequestDto);

        diaryRepository.save(diaryAddRequestDto.toEntity(imageList));
    }

    //일기 조회
    public DiaryResponseDto getDiary(Long diaryIndex) {
        Diary diary = diaryRepository.findById(diaryIndex)
                .orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryIndex));
        return new DiaryResponseDto(diary);
    }

    //일기 수정
    @Transactional
    public void updateDiary(DiaryRequestDto diaryUpdateRequestDto) {

        List<Image> imageList = saveAndGetImageList(diaryUpdateRequestDto);

        Optional<Diary> optionalDiary = diaryRepository.findById(diaryUpdateRequestDto.getDiaryIndex());
        Diary diary = optionalDiary.orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryUpdateRequestDto.getDiaryIndex()));

        for (Image image : diary.getImageList()) {
            for (Image newImage : imageList) {
                if (!image.getImageName().equals(newImage)) {
                    s3Service.deleteFile(image.getImageName());
                }
            }
        }
        diary.update(diaryUpdateRequestDto, imageList);

    }

    //일기 삭제
    @Transactional
    public void removeDiary(Long diaryIndex) {
        diaryRepository.deleteById(diaryIndex);
    }

    //일기 목록 조회
    public List<DiaryResponseDto> getDiaryList(Long memberIndex) {
        List<Diary> diaryList = diaryRepository.findByMemberIndex(memberIndex);

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for(Diary diary: diaryList) {
            responseDtoList.add(new DiaryResponseDto(diary));
        }

        return responseDtoList;
    }

    //이미지 s3에 저장하고 imageList 반환
    private List<Image> saveAndGetImageList(DiaryRequestDto diaryRequestDto) {
        List<MultipartFile> imageFileList = diaryRequestDto.getImageFileList();
        List<Image> imageList = new ArrayList<>();
        for (MultipartFile imageFile : imageFileList) {

            try {
                String imageLink = s3Service.saveFile(imageFile);
                imageList.add(new Image(imageFile.getOriginalFilename(), imageLink));
            } catch (IOException e) {
                throw new RuntimeException(e);
            }

        }

        return imageList;
    }
}

