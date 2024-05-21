package com.ssafy.diary.domain.diary.service;

import com.google.firebase.messaging.FirebaseMessagingException;
import com.ssafy.diary.domain.advice.repository.AdviceRepository;
import com.ssafy.diary.domain.advice.service.AdviceService;
import com.ssafy.diary.domain.analyze.dto.AnalyzeRequestDto;
import com.ssafy.diary.domain.analyze.repository.AnalyzeRepository;
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
import com.ssafy.diary.domain.notification.dto.KafkaMemberNotificationMessageRequestDto;
import com.ssafy.diary.domain.notification.dto.KafkaTokenNotificationMessageRequestDto;
import com.ssafy.diary.domain.notification.service.NotificationService;
import com.ssafy.diary.domain.openAI.dto.ChatGPTRequestDto;
import com.ssafy.diary.domain.openAI.service.OpenAIService;
import com.ssafy.diary.domain.s3.service.S3Service;
import com.ssafy.diary.global.exception.AlreadyExistsDiaryException;
import com.ssafy.diary.global.exception.DiaryNotFoundException;
import com.ssafy.diary.global.exception.UnauthorizedDiaryAccessException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class DiaryService {

    private final DiaryRepository diaryRepository;
    private final DiaryHashtagRepository diaryHashtagRepository;
    private final S3Service s3Service;
    private final AnalyzeService analyzeService;
    private final AnalyzeRepository analyzeRepository;
    private final AdviceService adviceService;
    private final AdviceRepository adviceRepository;
    private final OpenAIService openAIService;
    private final NotificationService notificationService;

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
//            diaryHashtagRepository.save(DiaryHashtag.builder()
//                    .diaryIndex(addedDiary.getDiaryIndex())
//                    .hashtagList(List.of(new String[]{"hashtag1", "hashtag2"}))
//                    .build());
        }
    }

    //해당 날짜에 일기 작성 여부 체크
    public Boolean checkDiaryWasWritten(LocalDate diarySetDate, Long memberIndex) {
        return diaryRepository.findByDiarySetDateAndMemberIndex(diarySetDate, memberIndex).isPresent()? true : false;
    }

    //일기 등록
    public void addDiary(DiaryAddRequestDto diaryAddRequestDto, MultipartFile[] imageFiles, Long memberIndex){

        if(diaryRepository.findByDiarySetDateAndMemberIndex(diaryAddRequestDto.getDiarySetDate(), memberIndex).isPresent()) {
            throw new AlreadyExistsDiaryException("해당 날짜에 이미 등록된 일기가 있습니다.");
        }

        List<Image> imageList = new ArrayList<>();

        if (imageFiles != null) {
            imageList = s3Service.saveAndGetImageList(imageFiles);
        }

        Diary diary = diaryRepository.save(diaryAddRequestDto.toEntity(imageList, memberIndex));
//        diaryHashtagRepository.save(diaryAddRequestDto.hashtagToDocument(diary.getDiaryIndex(), memberIndex));

        AnalyzeRequestDto analyzeRequestDto = AnalyzeRequestDto.builder()
                .diaryIndex(diary.getDiaryIndex())
                .diaryContent(diary.getDiaryContent())
                .build();

        analyzeService.addAnalyze(analyzeRequestDto).subscribe(body -> {
            //감정 수치 조정해서 postgreSQL에 저장하는 메서드 호출
            analyzeService.calculateEmotionPoints(diary);
            diaryRepository.save(diary);
            openAIService.generateAdvice(diary.getDiaryIndex(),memberIndex)
                    .subscribe(ChatGPTRequestDto -> {
                                if(!diaryRepository.existsDiaryByMemberIndex(memberIndex)){
                                    notificationService.sendKafkaFireBaseNotificationMessage(
                                            KafkaMemberNotificationMessageRequestDto.builder()
                                                    .title("분석 완료")
                                                    .body("첫 분석인가요? 확인해보세요!")
                                                    .memberIndex(memberIndex)
                                                    .build());
                                    return;
                                }
                                adviceService.updateAdviceByPeriod(memberIndex, diary.getDiarySetDate());
                            }
                    );
        });
    }

    //일기 조회
    public DiaryResponseDto getDiary(Long diaryIndex, Long memberIndex) {
        Diary diary = diaryRepository.findById(diaryIndex)
                .orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryIndex));

        if (diary.getMemberIndex() != memberIndex) {
            throw new UnauthorizedDiaryAccessException("해당 다이어리에 대한 권한이 없습니다: " + diaryIndex);
        }

        DiaryResponseDto diaryResponseDto = diary.toDto();

//        DiaryHashtag diaryHashtag = diaryHashtagRepository.findByDiaryIndex(diaryIndex);
//
//        if (diaryHashtag != null) {
//            diaryResponseDto.setHashtagList(diaryHashtag.getHashtagList());
//        }
        return diaryResponseDto;
    }

    //일기 수정
    @Transactional
    public void updateDiary(DiaryUpdateRequestDto diaryUpdateRequestDto, MultipartFile[] imageFiles, Long memberIndex) {

        Long diaryIndex = diaryUpdateRequestDto.getDiaryIndex();

        Optional<Diary> optionalDiary = diaryRepository.findById(diaryIndex);
        Diary diary = optionalDiary.orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryUpdateRequestDto.getDiaryIndex()));

        if (diary.getMemberIndex() != memberIndex) {
            throw new UnauthorizedDiaryAccessException("해당 다이어리에 대한 권한이 없습니다: " + diaryIndex);
        }

        diary.update(diaryUpdateRequestDto);

        // 기존 이미지 엔티티들을 삭제
        s3Service.deleteImagesFromS3(diary.getImageList());
        diary.getImageList().clear();

        // 새로운 이미지 엔티티들을 추가
        if (imageFiles != null) {
            List<Image> imageList = s3Service.saveAndGetImageList(imageFiles);
            diary.getImageList().addAll(imageList);
        }

        // Diary 엔티티 저장
        diaryRepository.save(diary);

        log.info("Updating diary with index: {}", diaryIndex);
        log.debug("Updated diary details: {}", diary);

        // 해시태그 수정
//        DiaryHashtag diaryHashtag = diaryHashtagRepository.findByDiaryIndex(diaryIndex);
//        Optional<DiaryHashtag> optionalDiaryHashtag = Optional.ofNullable(diaryHashtagRepository.findByDiaryIndex(diaryIndex));
//        DiaryHashtag diaryHashtag = optionalDiaryHashtag.orElseThrow(() -> new RuntimeException("해시태그를 찾을 수 없습니다. diaryIndex: " + diaryIndex));

//        diaryHashtag.setHashtagList(diaryUpdateRequestDto.getHashtagList());

//        log.debug("DiaryHashtag before update: {}", diaryHashtag);
//        System.out.println("DiaryHashtag before update: " + diaryHashtag.getHashtagIndex());

//        diaryHashtagRepository.save(diaryHashtag);

        adviceService.updateAdviceByPeriod(memberIndex, diary.getDiarySetDate());
    }

    //일기 삭제
    @Transactional
    public void removeDiary(Long diaryIndex, Long memberIndex) {
        Diary diary = diaryRepository.findById(diaryIndex).orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryIndex));

        if (diary.getMemberIndex() != memberIndex) {
            throw new UnauthorizedDiaryAccessException("해당 다이어리에 대한 권한이 없습니다: " + diaryIndex);
        }

        s3Service.deleteImagesFromS3(diary.getImageList());
//        diaryHashtagRepository.deleteByDiaryIndex(diaryIndex);
        analyzeRepository.deleteByDiaryIndex(diaryIndex);
        adviceRepository.deleteByMemberIndexAndDate(memberIndex, diary.getDiarySetDate(), diary.getDiarySetDate());
        diaryRepository.deleteById(diaryIndex);

        adviceService.updateAdviceByPeriod(memberIndex, diary.getDiarySetDate());
    }

    //일기 목록 조회
    public List<DiaryResponseDto> getDiaryList(Long memberIndex) {
        List<Diary> diaryList = diaryRepository.findByMemberIndexOrderByDiarySetDate(memberIndex);

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for (Diary diary : diaryList) {
            DiaryResponseDto diaryResponseDto = diary.toDto();

//            DiaryHashtag diaryHashtag = diaryHashtagRepository.findByDiaryIndex(diary.getDiaryIndex());
//
//            if (diaryHashtag != null) {
//                diaryResponseDto.setHashtagList(diaryHashtag.getHashtagList());
//            }
            responseDtoList.add(diaryResponseDto);
        }
        return responseDtoList;
    }

    //특정 기간동안의 일기 리스트 조회(통계 내기 위함)
    public List<DiaryResponseDto> getDiaryListByPeriod(Long memberIndex, DiaryListByPeriodRequestDto diaryListByPeriodRequestDto) {
        List<Diary> diaryList = diaryRepository.findByMemberIndexAndDiarySetDateOrderByDiarySetDate(memberIndex, diaryListByPeriodRequestDto.getStartDate(), diaryListByPeriodRequestDto.getEndDate());

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for(Diary diary: diaryList) {
            DiaryResponseDto diaryResponseDto = diary.toDto();

//            DiaryHashtag diaryHashtag = diaryHashtagRepository.findByDiaryIndex(diary.getDiaryIndex());

//            if (diaryHashtag != null) {
//                diaryResponseDto.setHashtagList(diaryHashtag.getHashtagList());
//            }
            responseDtoList.add(diaryResponseDto);
        }
        return responseDtoList;
    }

    //제목으로 검색
    public List<DiaryResponseDto> searchDiaryListByTitle(Long memberIndex, String keyword) {
        List<Diary> diaryList = diaryRepository.findByMemberIndexAndDiaryTitleContainingOrderByDiarySetDate(memberIndex, keyword);

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for (Diary diary : diaryList) {
            DiaryResponseDto diaryResponseDto = diary.toDto();

//            DiaryHashtag diaryHashtag = diaryHashtagRepository.findByDiaryIndex(diary.getDiaryIndex());
//
//            if (diaryHashtag != null) {
//                diaryResponseDto.setHashtagList(diaryHashtag.getHashtagList());
//            }
            responseDtoList.add(diaryResponseDto);
        }
        return responseDtoList;
    }

    //제목+내용으로 검색
    public List<DiaryResponseDto> searchDiaryListByTitleAndTitle(Long memberIndex, String keyword) {
        List<Diary> diaryList = diaryRepository.findByMemberIndexAndDiaryTitleAndContentContainingOrderByDiarySetDate(memberIndex, keyword);

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for (Diary diary : diaryList) {
            DiaryResponseDto diaryResponseDto = diary.toDto();

//            DiaryHashtag diaryHashtag = diaryHashtagRepository.findByDiaryIndex(diary.getDiaryIndex());
//
//            if (diaryHashtag != null) {
//                diaryResponseDto.setHashtagList(diaryHashtag.getHashtagList());
//            }
            responseDtoList.add(diaryResponseDto);
        }
        return responseDtoList;
    }

    //해시태그로 검색
    public List<DiaryResponseDto> searchDiaryListByHashtag(Long memberIndex, String keyword) {
        List<DiaryHashtag> diaryHashtagList = diaryHashtagRepository.findByMemberIndexAndHashtagListContaining(memberIndex, keyword);
        System.out.println(diaryHashtagList.get(0).toString());

        List<DiaryResponseDto> responseDtoList = new ArrayList<>();
        for (DiaryHashtag diaryHashtag : diaryHashtagList) {
            Diary diary = diaryRepository.findById(diaryHashtag.getDiaryIndex()).orElseThrow(() -> new DiaryNotFoundException("다이어리를 찾을 수 없습니다. diaryIndex: " + diaryHashtag.getDiaryIndex()));
            DiaryResponseDto diaryResponseDto = diary.toDto();

            diaryResponseDto.setHashtagList(diaryHashtag.getHashtagList());
            responseDtoList.add(diaryResponseDto);
        }

        // responseDtoList를 diarySetDate 필드를 기준으로 내림차순 정렬
        Collections.sort(responseDtoList, new Comparator<DiaryResponseDto>() {
            @Override
            public int compare(DiaryResponseDto o1, DiaryResponseDto o2) {
                return o2.getDiarySetDate().compareTo(o1.getDiarySetDate()); // 비교 로직 수정
            }
        });

        return responseDtoList;
    }

}


