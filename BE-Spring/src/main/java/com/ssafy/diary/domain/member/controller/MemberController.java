package com.ssafy.diary.domain.member.controller;

import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.member.dto.MemberInfoResponseDto;
import com.ssafy.diary.domain.member.dto.MemberModifyRequestDto;
import com.ssafy.diary.domain.member.dto.MemberOauthRegisterRequestDto;
import com.ssafy.diary.domain.member.dto.MemberRegisterRequestDto;
import com.ssafy.diary.domain.member.service.MemberService;
import com.ssafy.diary.global.constant.AuthType;
import com.ssafy.diary.global.exception.AlreadyExistsMemberException;
import lombok.RequiredArgsConstructor;
import org.apache.coyote.BadRequestException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/member")
@RequiredArgsConstructor
public class MemberController {
    final private MemberService memberService;

    @GetMapping("/check")
    public ResponseEntity<String> checkMemberId(@RequestParam("id") String id) {
        if (memberService.checkExistMemberId(id, AuthType.LOCAL)) {
            throw new AlreadyExistsMemberException("member ID " + id + " is exists");
        }
        return ResponseEntity.ok().build();
    }

    @PostMapping("/register")
    public ResponseEntity<Object> authJoin(@RequestBody MemberRegisterRequestDto memberRegisterRequestDto) {
        memberService.registerMember(memberRegisterRequestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body("register successfully");
    }

    @GetMapping("/my")
    public ResponseEntity<MemberInfoResponseDto> memberInfo(@AuthenticationPrincipal PrincipalMember principalMember) {

        return ResponseEntity.ok().body(memberService.getMemberInfo(principalMember.getIndex()));
    }
    @PutMapping("/auth")
    public ResponseEntity<String> memberPasswordUpdate(@AuthenticationPrincipal PrincipalMember principalMember, MemberModifyRequestDto memberModifyRequestDto) throws BadRequestException {
        if(!memberModifyRequestDto.getMemberNewPassword().isEmpty() &&!memberModifyRequestDto.getMemberOldPassword().isEmpty()) {
            memberService.updateMemberPassword(principalMember.getIndex(), memberModifyRequestDto);

            return ResponseEntity.ok().body("member password updated successfully");
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("password is empty");
    }
    @PostMapping("/oauth2/register")
    public ResponseEntity<String> memberOauth2Register(MemberOauthRegisterRequestDto memberOauthRegisterRequestDto) {
        memberService.registerOauth2Member(memberOauthRegisterRequestDto);
        return ResponseEntity.ok().body("oauth2 login successfully");
    }
    @PutMapping("/")
    public ResponseEntity<String> memberInfoUpdate(@AuthenticationPrincipal PrincipalMember principalMember, MemberModifyRequestDto memberModifyRequestDto) throws BadRequestException {
            memberService.updateMemberInfo(principalMember.getIndex(), memberModifyRequestDto);
            return ResponseEntity.ok().body("member info updated successfully");
    }
}
