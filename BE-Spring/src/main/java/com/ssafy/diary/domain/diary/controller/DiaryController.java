package com.ssafy.diary.domain.diary.controller;

import com.amazonaws.Response;
import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.diary.dto.*;
import com.ssafy.diary.domain.diary.service.DiaryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Diary", description = "다이어리 API")
@RestController
@RequestMapping("/api/diary")
@RequiredArgsConstructor
public class DiaryController {

    private final DiaryService diaryService;

    //더미데이터 생성
    @Operation(summary = "더미 데이터 생성", description = "24.01.01 ~ 24.04.29 기간의 더미데이터 생성")
    @GetMapping("/dummy")
    public ResponseEntity<Object> createDummy(@AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        diaryService.createDummyData(memberIndex);
        return ResponseEntity.status(HttpStatus.CREATED).body("dummy creating succeeded");
    }

    //해당 날짜에 일기 작성 여부 체크
    @Operation(summary = "일기 작성 여부 체크", description = "해당 날짜에 일기 장성 여부 체크")
    @GetMapping("/check")
    public ResponseEntity<Boolean> checkDiaryWasWritten(LocalDate diarySetDate, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        return ResponseEntity.ok(diaryService.checkDiaryWasWritten(diarySetDate, memberIndex));
    }

    //일기 등록
    @Operation(summary = "일기 등록", description = "일기 등록. diarySetDate, diaryTitle, diaryContent 필수")
    @PostMapping(consumes = "multipart/form-data")
    public ResponseEntity<Object> postDiary(@RequestPart(name = "data") DiaryAddRequestDto diaryAddRequestDto, @RequestPart(value = "imageFiles",required = false) MultipartFile[] imageFiles, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        diaryService.addDiary(diaryAddRequestDto, imageFiles, memberIndex);
        return ResponseEntity.status(HttpStatus.CREATED).body("diary posting succeeded");
    }

//    //일기 등록
//    @Operation(summary = "일기 등록", description = "일기 등록. diarySetDate, diaryTitle, diaryContent 필수")
//    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
//    public ResponseEntity<Object> postDiary(@ModelAttribute DiaryAddRequestDto diaryAddRequestDto, @AuthenticationPrincipal PrincipalMember principalMember) {
//        Long memberIndex = principalMember.getIndex();
//        diaryService.addDiary(diaryAddRequestDto, memberIndex);
//        return ResponseEntity.status(HttpStatus.CREATED).body("diary posting succeeded");
//    }

    //일기 조회
    @Operation(summary = "일기 하나 조회", description = "일기 하나 조회")
    @GetMapping
    public ResponseEntity<DiaryResponseDto> getDiary(Long diaryIndex, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        DiaryResponseDto diaryResponseDto = diaryService.getDiary(diaryIndex, memberIndex);
        return ResponseEntity.ok(diaryResponseDto);
    }

    //일기 수정
    @Operation(summary = "일기 수정", description = "일기 수정. diaryIndex, diaryTitle, diaryContent 필수")
    @PutMapping(consumes = "multipart/form-data")
    public ResponseEntity<Object> putDiary(@RequestPart DiaryUpdateRequestDto diaryUpdateRequestDto, @RequestPart(value = "imageFiles",required = false) MultipartFile[] imageFiles, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        diaryService.updateDiary(diaryUpdateRequestDto, imageFiles, memberIndex);
        return ResponseEntity.ok("diary updating succeeded");
    }

    //일기 삭제
    @Operation(summary = "일기 삭제", description = "일기 삭제")
    @DeleteMapping
    public ResponseEntity<Object> deleteDiary(@RequestParam Long diaryIndex, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        diaryService.removeDiary(diaryIndex, memberIndex);
        return ResponseEntity.ok("diary deletion succeeded");
    }

    //일기 목록 조회
    @Operation(summary = "일기 목록 조회(전체)", description = "일기 전체 목록 조회")
    @GetMapping("/list")
    public ResponseEntity<List<DiaryResponseDto>> getDairyList(@AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        List<DiaryResponseDto> diaryList = diaryService.getDiaryList(memberIndex);
        return ResponseEntity.ok(diaryList);
    }

    //특정 기간의 일기 목록 조회
    @Operation(summary = "일기 목록 조회(특정 기간)", description = "특정 기간 동안의 일기 조회")
    @PostMapping("/list/period")
    public ResponseEntity<List<DiaryResponseDto>> getDiaryListByPeriod(@RequestBody DiaryListByPeriodRequestDto diaryListByPeriodRequestDto, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        List<DiaryResponseDto> diaryList = diaryService.getDiaryListByPeriod(memberIndex, diaryListByPeriodRequestDto);
        return ResponseEntity.ok(diaryList);
    }

    //일기 검색(제목)
    @Operation(summary = "일기 검색(제목)", description = "제목에 특정 키워드를 포함하는 일기 조회")
    @GetMapping("search/title")
    public ResponseEntity<List<DiaryResponseDto>> getDiaryListByTitle(@RequestParam String keyword, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        List<DiaryResponseDto> diaryList = diaryService.searchDiaryListByTitle(memberIndex, keyword);
        return ResponseEntity.ok(diaryList);
    }

    //일기 검색(제목+내용)
    @Operation(summary = "일기 검색(제목+내용)", description = "제목과 내용에 특정 키워드를 포함하는 일기 조회")
    @GetMapping("search/title+content")
    public ResponseEntity<List<DiaryResponseDto>> getDiaryListByTitleAndContent(@RequestParam String keyword, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        List<DiaryResponseDto> diaryList = diaryService.searchDiaryListByTitleAndTitle(memberIndex, keyword);
        return ResponseEntity.ok(diaryList);
    }

    //일기 검색(해시태그)
    @Operation(summary = "일기 검색(해시태그)", description = "'싸피'를 검색했을 때 정확하게 '싸피'라는 해시태그가 있는 일기만 검색됨. 해시태그를 카테고리 느낌으로 사용")
    @GetMapping("search/hashtag")
    public ResponseEntity<List<DiaryResponseDto>> getDiaryListByHashTag(@RequestParam String keyword, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        List<DiaryResponseDto> diaryList = diaryService.searchDiaryListByHashtag(memberIndex, keyword);
        return ResponseEntity.ok(diaryList);
    }

}
