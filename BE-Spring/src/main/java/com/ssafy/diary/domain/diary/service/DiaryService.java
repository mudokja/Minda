package com.ssafy.diary.domain.diary.service;

import com.ssafy.diary.domain.diary.dto.DiaryListByPeriodRequestDto;
import com.ssafy.diary.domain.diary.dto.DiaryRequestDto;
import com.ssafy.diary.domain.diary.dto.DiaryResponseDto;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import com.ssafy.diary.domain.diary.repository.DiaryRepository;
import com.ssafy.diary.domain.diary.repository.ImageRepository;
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
    public void addDiary(DiaryRequestDto diaryAddRequestDto, MultipartFile[] imageFiles) {
        List<Image> imageList = new ArrayList<>();

        if (imageFiles != null) {
            imageList = saveAndGetImageList(imageFiles);
        }

        diaryRepository.save(diaryAddRequestDto.toEntity(imageList));
    }

    //일기 조회
    public DiaryResponseDto getDiary(Long diaryIndex) {
        Diary diary = diaryRepository.findById(diaryIndex)
                .orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryIndex));
        return diary.toDto();
    }

//    //일기 수정
//    @Transactional
//    public void updateDiary(DiaryRequestDto diaryUpdateRequestDto, MultipartFile[] imageFiles) {
//
//        List<Image> imageList = new ArrayList<>();
//
//        if (imageFiles != null) {
//            imageList = saveAndGetImageList(imageFiles);
//        }
//
//        Optional<Diary> optionalDiary = diaryRepository.findById(diaryUpdateRequestDto.getDiaryIndex());
//        System.out.println(optionalDiary);
//        Diary diary = optionalDiary.orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryUpdateRequestDto.getDiaryIndex()));
//
//        for (Image image : diary.getImageList()) {
//            for (Image newImage : imageList) {
//                if (!image.getImageName().equals(newImage)) {
//                    s3Service.deleteFile(image.getImageName());
//                }
//            }
//        }
//        diary.update(diaryUpdateRequestDto, imageList);
//
//    }

    //일기 수정
    @Transactional
    public void updateDiary(DiaryRequestDto diaryUpdateRequestDto, MultipartFile[] imageFiles) {

        Optional<Diary> optionalDiary = diaryRepository.findById(diaryUpdateRequestDto.getDiaryIndex());

        Diary diary = optionalDiary.orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryUpdateRequestDto.getDiaryIndex()));

        diary.update(diaryUpdateRequestDto);

        // 기존 이미지 엔티티들을 삭제
        deleteImageFromS3(diary.getImageList());
        diary.getImageList().clear();

        // 새로운 이미지 엔티티들을 추가
        if (imageFiles != null) {
            List<Image> imageList = saveAndGetImageList(imageFiles);
            diary.getImageList().addAll(imageList);
        }

        // Diary 엔티티 저장
        diaryRepository.save(diary);

    }

    //일기 삭제
    @Transactional
    public void removeDiary(Long diaryIndex) {
        Optional<Diary> optionalDiary = diaryRepository.findById(diaryIndex);
        Diary diary = diaryRepository.findById(diaryIndex).orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryIndex));

        deleteImageFromS3(diary.getImageList());
        diaryRepository.deleteById(diaryIndex);
    }

    //일기 목록 조회
    public List<DiaryResponseDto> getDiaryList(Long memberIndex) {
        List<Diary> diaryList = diaryRepository.findByMemberIndex(memberIndex);

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for (Diary diary : diaryList) {
            responseDtoList.add(diary.toDto());
        }

        return responseDtoList;
    }

    //특정 기간동안의 일기 리스트 조회(통계 내기 위함)
    public List<DiaryResponseDto> getDiaryListByPeriod(DiaryListByPeriodRequestDto diaryListByPeriodRequestDto, Long memberIndex) {
        List<Diary> diaryList = diaryRepository.findByDiarySetDate(diaryListByPeriodRequestDto.getStartDate(), diaryListByPeriodRequestDto.getEndDate());

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for(Diary diary: diaryList) {
            responseDtoList.add(diary.toDto());
        }
        return responseDtoList;
    }


    //이미지 s3에 저장하고 imageList 반환
    private List<Image> saveAndGetImageList(MultipartFile[] imageFiles) {
        List<Image> imageList = new ArrayList<>();
        for (MultipartFile imageFile : imageFiles) {
            try {
                String imageLink = s3Service.saveFile(imageFile);
                imageList.add(Image.builder()
                        .imageName(imageFile.getOriginalFilename())
                        .imageLink(imageLink)
                        .build());
            } catch (IOException e) {
                throw new RuntimeException(e);
            }

        }

        return imageList;
    }

    //이미지url에서 파일이름 추출해서 삭제
    private void deleteImageFromS3(List<Image> imageList) {
        for (Image image : imageList) {
            String imageName;
            int lastSlashIndex = image.getImageLink().lastIndexOf('/');
            if (lastSlashIndex != -1) {
                imageName = image.getImageLink().substring(lastSlashIndex + 1);
                s3Service.deleteFile(imageName);
            }
        }
    }

}

