package com.ssafy.diary.domain.diary.service;

import com.ssafy.diary.domain.analyze.dto.AnalyzeRequestDto;
import com.ssafy.diary.domain.analyze.service.AnalyzeService;
import com.ssafy.diary.domain.diary.dto.DiaryAddRequestDto;
import com.ssafy.diary.domain.diary.dto.DiaryListByPeriodRequestDto;
import com.ssafy.diary.domain.diary.dto.DiaryUpdateRequestDto;
import com.ssafy.diary.domain.diary.dto.DiaryResponseDto;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.entity.Image;
import com.ssafy.diary.domain.diary.model.DiaryHashtag;
import com.ssafy.diary.domain.diary.repository.DiaryHashtagRepository;
import com.ssafy.diary.domain.diary.repository.DiaryRepository;
import com.ssafy.diary.domain.s3.service.S3Service;
import com.ssafy.diary.global.exception.DiaryNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DiaryService {

    private final DiaryRepository diaryRepository;
    private final DiaryHashtagRepository diaryHashtagRepository;
    private final S3Service s3Service;
    private final AnalyzeService analyzeService;

    //더미데이터 생성
    public void createDummyData(Long memberIndex) {
        LocalDate startDate = LocalDate.of(2024, 1, 1); // 시작 날짜
        LocalDate endDate = LocalDate.of(2024, 4, 29); // 종료 날짜
        long daysBetween = ChronoUnit.DAYS.between(startDate, endDate); // 시작과 종료 사이의 일수 계산

        for (long i = 0; i <= daysBetween; i++) {
            LocalDate currentDate = startDate.plusDays(i);
            List<Image> imageList = new ArrayList<>();
            imageList.add(Image.builder()
                    .imageName("Dummy")
                    .imageLink("https://ssafy-stella-bucket.s3.ap-northeast-2.amazonaws.com/bd629bbc-4063-4a41-bb59-7fa04cff4c8d.jpg")
                    .build());

            Diary diary = Diary.builder()
                    .memberIndex(memberIndex)
                    .diarySetDate(currentDate)
                    .diaryTitle("Dummy Title " + i)
                    .diaryContent("Dummy Content " + i)
                    .diaryHappiness((Math.random() * 101))
                    .diarySadness((Math.random() * 101))
                    .diaryFear((Math.random() * 101))
                    .diaryAnger((Math.random() * 101))
                    .diarySurprise((Math.random() * 101))
                    .imageList(imageList)
                    .build();
            Diary addedDiary = diaryRepository.save(diary);
            diaryHashtagRepository.save(DiaryHashtag.builder()
                    .diaryIndex(addedDiary.getDiaryIndex())
                    .hashtagList(List.of(new String[]{"hashtag1", "hashtag2"}))
                    .build());
        }
    }

    //일기 등록
    public void addDiary(DiaryAddRequestDto diaryAddRequestDto, MultipartFile[] imageFiles, Long memberIndex) {
        List<Image> imageList = new ArrayList<>();

        if (imageFiles != null) {
            imageList = saveAndGetImageList(imageFiles);
        }

        Diary diary = diaryRepository.save(diaryAddRequestDto.toEntity(imageList, memberIndex));
        diaryHashtagRepository.save(diaryAddRequestDto.hashtagToDocument(diary.getDiaryIndex()));

        AnalyzeRequestDto analyzeRequestDto = AnalyzeRequestDto.builder()
                .diaryIndex(diary.getDiaryIndex())
                .diaryContent(diary.getDiaryContent())
                .build();

        analyzeService.addAnalyze(analyzeRequestDto).subscribe(body -> {
            //감정 수치 조정해서 postgreSQL에 저장하는 메서드 호출
        });
    }

//    //일기 등록
//    public void addDiary(DiaryAddRequestDto diaryAddRequestDto, Long memberIndex) {
//        List<Image> imageList = new ArrayList<>();
//
//        if (diaryAddRequestDto.getImageFiles() != null) {
//            imageList = saveAndGetImageList(diaryAddRequestDto.getImageFiles());
//        }
//
//        Diary diary = diaryRepository.save(diaryAddRequestDto.toEntity(imageList, memberIndex));
//        diaryHashtagRepository.save(diaryAddRequestDto.hashtagToDocument(diary.getDiaryIndex()));
//
//        AnalyzeRequestDto analyzeRequestDto = AnalyzeRequestDto.builder()
//                .diaryIndex(diary.getDiaryIndex())
//                .diaryContent(diary.getDiaryContent())
//                .build();
//
//        analyzeService.addAnalyze(analyzeRequestDto).subscribe(body -> {
//            //감정 수치 조정해서 postgreSQL에 저장하는 메서드 호출
//        });
//    }

    //일기 조회
    public DiaryResponseDto getDiary(Long diaryIndex) {
        Diary diary = diaryRepository.findById(diaryIndex)
                .orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryIndex));
        DiaryResponseDto diaryResponseDto = diary.toDto();

        DiaryHashtag diaryHashtag = diaryHashtagRepository.findByDiaryIndex(diaryIndex);

        if (diaryHashtag != null) {
            diaryResponseDto.setHashtagList(diaryHashtag.getHashtagList());
        }
        return diaryResponseDto;
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
    public void updateDiary(DiaryUpdateRequestDto diaryUpdateRequestDto, MultipartFile[] imageFiles) {

        Long diaryIndex = diaryUpdateRequestDto.getDiaryIndex();

        Optional<Diary> optionalDiary = diaryRepository.findById(diaryIndex);
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

        // 해시태그 수정
        DiaryHashtag diaryHashtag = diaryHashtagRepository.findByDiaryIndex(diaryIndex);
        System.out.println(diaryHashtag);
        diaryHashtag.setHashtagList(diaryUpdateRequestDto.getHashtagList());
        diaryHashtagRepository.save(diaryHashtag);
    }

    //일기 삭제
    @Transactional
    public void removeDiary(Long diaryIndex) {
        Optional<Diary> optionalDiary = diaryRepository.findById(diaryIndex);
        Diary diary = diaryRepository.findById(diaryIndex).orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryIndex));

        deleteImageFromS3(diary.getImageList());
        diaryHashtagRepository.deleteByDiaryIndex(diaryIndex);
        diaryRepository.deleteById(diaryIndex);
    }

    //일기 목록 조회
    public List<DiaryResponseDto> getDiaryList(Long memberIndex) {
        List<Diary> diaryList = diaryRepository.findByMemberIndex(memberIndex);

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for (Diary diary : diaryList) {
            DiaryResponseDto diaryResponseDto = diary.toDto();

            DiaryHashtag diaryHashtag = diaryHashtagRepository.findByDiaryIndex(diary.getDiaryIndex());

            if (diaryHashtag != null) {
                diaryResponseDto.setHashtagList(diaryHashtag.getHashtagList());
            }
            responseDtoList.add(diaryResponseDto);
        }
        return responseDtoList;
    }

    //특정 기간동안의 일기 리스트 조회(통계 내기 위함)
    public List<DiaryResponseDto> getDiaryListByPeriod(Long memberIndex, DiaryListByPeriodRequestDto diaryListByPeriodRequestDto) {
        List<Diary> diaryList = diaryRepository.findByMemberIndexAndDiarySetDate(memberIndex, diaryListByPeriodRequestDto.getStartDate(), diaryListByPeriodRequestDto.getEndDate());

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for(Diary diary: diaryList) {
            DiaryResponseDto diaryResponseDto = diary.toDto();

            DiaryHashtag diaryHashtag = diaryHashtagRepository.findByDiaryIndex(diary.getDiaryIndex());

            if (diaryHashtag != null) {
                diaryResponseDto.setHashtagList(diaryHashtag.getHashtagList());
            }
            responseDtoList.add(diaryResponseDto);
        }
        return responseDtoList;
    }

    //제목으로 검색
    public List<DiaryResponseDto> searchDiaryListByTitle(Long memberIndex, String keyword) {
        List<Diary> diaryList = diaryRepository.findByMemberIndexAndDiaryTitleContaining(memberIndex, keyword);

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for (Diary diary : diaryList) {
            DiaryResponseDto diaryResponseDto = diary.toDto();

            DiaryHashtag diaryHashtag = diaryHashtagRepository.findByDiaryIndex(diary.getDiaryIndex());

            if (diaryHashtag != null) {
                diaryResponseDto.setHashtagList(diaryHashtag.getHashtagList());
            }
            responseDtoList.add(diaryResponseDto);
        }
        return responseDtoList;
    }

    //해시태그로 검색
    public List<DiaryResponseDto> searchDiaryListByHashtag(Long memberIndex, String keyword) {
        List<DiaryHashtag> diaryHashtagList = diaryHashtagRepository.findByMemberIndexAndHashtagListContaining(memberIndex, keyword);

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for (DiaryHashtag diaryHashtag : diaryHashtagList) {
            Diary diary = diaryRepository.findById(diaryHashtag.getDiaryIndex()).orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryHashtag.getDiaryIndex()));
            DiaryResponseDto diaryResponseDto = diary.toDto();

            diaryResponseDto.setHashtagList(diaryHashtag.getHashtagList());
            responseDtoList.add(diaryResponseDto);
        }
        return responseDtoList;
    }

//    //이미지 s3에 저장하고 imageList 반환
//    private List<Image> saveAndGetImageList(MultipartFile[] imageFiles) {
//        List<Image> imageList = new ArrayList<>();
//        for (MultipartFile imageFile : imageFiles) {
//            try {
//                String imageLink = s3Service.saveFile(imageFile);
//                imageList.add(Image.builder()
//                        .imageName(imageFile.getOriginalFilename())
//                        .imageLink(imageLink)
//                        .build());
//            } catch (IOException e) {
//                throw new RuntimeException(e);
//            }
//
//        }
//
//        return imageList;
//    }

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


