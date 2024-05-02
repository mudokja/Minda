package com.ssafy.diary.domain.diary.controller;

import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.auth.service.JwtService;
import com.ssafy.diary.domain.diary.dto.DiaryListByPeriodRequestDto;
import com.ssafy.diary.domain.diary.dto.DiaryRequestDto;
import com.ssafy.diary.domain.diary.dto.DiaryResponseDto;
import com.ssafy.diary.domain.diary.dto.ImageUploadDto;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.service.DiaryService;
import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.global.util.JwtUtil;
import io.jsonwebtoken.Claims;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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

    //일기 등록
    @Operation(summary = "일기 등록", description = "일기 등록. diaryIndex는 보내지 마세요. diarySetDate, diaryTitle, diaryContent 필수")
    @PostMapping(consumes = "multipart/form-data")
    public ResponseEntity<Object> postDiary(@RequestPart DiaryRequestDto diaryAddRequestDto, @RequestPart(value = "imageFiles",required = false) MultipartFile[] imageFiles, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        diaryService.addDiary(diaryAddRequestDto, imageFiles, memberIndex);
        return ResponseEntity.status(HttpStatus.CREATED).body("diary posting succeeded");
    }

    //일기 조회
    @Operation(summary = "일기 하나 조회", description = "일기 하나 조회")
    @GetMapping
    public ResponseEntity<DiaryResponseDto> getDiary(Long diaryIndex) {
        DiaryResponseDto diaryResponseDto = diaryService.getDiary(diaryIndex);
        return ResponseEntity.ok(diaryResponseDto);
    }

    //일기 수정
    @Operation(summary = "일기 수정", description = "일기 수정. diaryIndex, diarySetDate, diaryTitle, diaryContent 필수")
    @PutMapping(consumes = "multipart/form-data")
    public ResponseEntity<Object> putDiary(@RequestPart DiaryRequestDto diaryUpdateRequestDto, @RequestPart(value = "imageFiles",required = false) MultipartFile[] imageFiles) {
        diaryService.updateDiary(diaryUpdateRequestDto, imageFiles);
        return ResponseEntity.ok("diary updating succeeded");
    }

    //일기 삭제
    @Operation(summary = "일기 삭제", description = "일기 삭제")
    @DeleteMapping
    public ResponseEntity<Object> deleteDiary(@RequestParam Long diaryIndex) {
        System.out.println("diaryController: " + diaryIndex);
        diaryService.removeDiary(diaryIndex);
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

    //일기 검색(해시태그)
    @Operation(summary = "일기 검색(해시태그)", description = "미완성. 검색 방법 고민. 예를 들어 '싸피'를 검색했을 때 정확하게 '싸피'라는 해시태그가 있는 일기만 검색되어야 하는지, '싸피데이'같이 '싸피'라는 키워드를 포함하는 해시태그가 존재하는 일기도 함께 검색되어야 하는지?")
    @GetMapping("search/hashtag")
    public ResponseEntity<List<DiaryResponseDto>> getDiaryListByHashTag(@RequestParam String keyword, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        List<DiaryResponseDto> diaryList = diaryService.searchDiaryListByHashtag(memberIndex, keyword);
        return ResponseEntity.ok(diaryList);
    }

}
