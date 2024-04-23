package com.ssafy.diary.domain.diary.controller;

import com.ssafy.diary.domain.auth.service.JwtService;
import com.ssafy.diary.domain.diary.dto.DiaryRequestDto;
import com.ssafy.diary.domain.diary.entity.Diary;
import com.ssafy.diary.domain.diary.service.DiaryService;
import com.ssafy.diary.global.util.JwtUtil;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/diary")
@RequiredArgsConstructor
public class DiaryController {

    private final DiaryService diaryService;
    private final JwtUtil jwtUtil;
    private final JwtService jwtService;

    //일기 등록
    @PostMapping("/diary")
    public ResponseEntity<Object> postDiary(@RequestBody DiaryRequestDto diaryAddRequestDto, HttpServletRequest request) {
        String accessToken = jwtUtil.resolveToken(request);
        Claims claims = jwtService.parseClaims(accessToken);
        Long memberIndex = claims.get("memberIndex", Long.class);
        diaryAddRequestDto.setMemberIndex(memberIndex);
        diaryService.addDairy(diaryAddRequestDto.toEntity());
        return ResponseEntity.status(HttpStatus.CREATED).body("diary posting succeeded");
    }

    //일기 조회
    @GetMapping("/diary")
    public ResponseEntity<Diary> getDiary(Long diaryIndex) {
        Diary diary = diaryService.getDiary(diaryIndex);
        return ResponseEntity.ok(diary);
    }

    //일기 수정
    @PutMapping("/diary")
    public ResponseEntity<Object> putDiary(@RequestBody DiaryRequestDto diaryUpdateRequestDto) {
        diaryService.updateDiary(diaryUpdateRequestDto);
        return ResponseEntity.ok("diary updating succeeded");
    }

    //일기 삭제
    @DeleteMapping("/diary")
    public ResponseEntity<Object> deleteDiary(@RequestParam Long diaryIndex) {
        diaryService.removeDiary(diaryIndex);
        return ResponseEntity.ok("diary deletion succeeded");
    }

    //일기 목록 조회
    @GetMapping("/diary/list")
    public ResponseEntity<List<Diary>> getDairyList(HttpServletRequest request) {
        String accessToken = jwtUtil.resolveToken(request);
        Claims claims = jwtService.parseClaims(accessToken);
        Long memberIndex = claims.get("memberIndex", Long.class);
        List<Diary> diaryList = diaryService.getDiaryList(memberIndex);
        return ResponseEntity.ok(diaryList);
    }

}
