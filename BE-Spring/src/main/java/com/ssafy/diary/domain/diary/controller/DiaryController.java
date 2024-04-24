package com.ssafy.diary.domain.diary.controller;

import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.auth.service.JwtService;
import com.ssafy.diary.domain.diary.dto.DiaryRequestDto;
import com.ssafy.diary.domain.diary.dto.DiaryResponseDto;
import com.ssafy.diary.domain.diary.dto.ImageUploadDto;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.service.DiaryService;
import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.global.util.JwtUtil;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/diary")
@RequiredArgsConstructor
public class DiaryController {

    private final DiaryService diaryService;

    //일기 등록
    @PostMapping(consumes = "multipart/form-data")
    public ResponseEntity<Object> postDiary(@RequestPart DiaryRequestDto diaryAddRequestDto, @RequestPart(value = "imageFiles",required = false) MultipartFile[] imageFiles, @AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        diaryAddRequestDto.setMemberIndex(memberIndex);
        diaryService.addDiary(diaryAddRequestDto, imageFiles);
        return ResponseEntity.status(HttpStatus.CREATED).body("diary posting succeeded");
    }

    //일기 조회
    @GetMapping
    public ResponseEntity<DiaryResponseDto> getDiary(Long diaryIndex) {
        DiaryResponseDto diaryResponseDto = diaryService.getDiary(diaryIndex);
        return ResponseEntity.ok(diaryResponseDto);
    }

    //일기 수정
    @PutMapping(consumes = "multipart/form-data")
    public ResponseEntity<Object> putDiary(@RequestPart DiaryRequestDto diaryUpdateRequestDto, @RequestPart(value = "imageFiles",required = false) MultipartFile[] imageFiles) {
        diaryService.updateDiary(diaryUpdateRequestDto, imageFiles);
        return ResponseEntity.ok("diary updating succeeded");
    }

    //일기 삭제
    @DeleteMapping
    public ResponseEntity<Object> deleteDiary(@RequestParam Long diaryIndex) {
        diaryService.removeDiary(diaryIndex);
        return ResponseEntity.ok("diary deletion succeeded");
    }

    //일기 목록 조회
    @GetMapping("/list")
    public ResponseEntity<List<DiaryResponseDto>> getDairyList(@AuthenticationPrincipal PrincipalMember principalMember) {
        Long memberIndex = principalMember.getIndex();
        List<DiaryResponseDto> diaryList = diaryService.getDiaryList(memberIndex);
        return ResponseEntity.ok(diaryList);
    }

}
