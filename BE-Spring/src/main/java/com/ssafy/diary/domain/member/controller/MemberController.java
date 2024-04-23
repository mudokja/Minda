package com.ssafy.diary.domain.member.controller;

import com.ssafy.diary.domain.member.dto.MemberRegisterRequestDto;
import com.ssafy.diary.domain.member.service.MemberService;
import com.ssafy.diary.global.exception.AlreadyExistsMemberException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/member")
@RequiredArgsConstructor
public class MemberController {
    final private MemberService memberService;
    @GetMapping("/check")
    public ResponseEntity<String> checkMemberId(@RequestParam("id") String id){
        if(memberService.checkExistMemberId(id)){
            throw new AlreadyExistsMemberException("member ID "+id+ " is exists");
        }
        return ResponseEntity.ok().build();
    }
    @PostMapping("/register")
    public ResponseEntity<Object> authJoin(@RequestBody MemberRegisterRequestDto memberRegisterRequestDto) {
        memberService.registerMember(memberRegisterRequestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body("register successfully");
    }
}
