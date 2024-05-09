package com.ssafy.diary.domain.member.controller;

import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.member.dto.MemberInfoResponseDto;
import com.ssafy.diary.domain.member.dto.MemberInfoUpdateRequestDto;
import com.ssafy.diary.domain.member.dto.MemberRegisterRequestDto;
import com.ssafy.diary.domain.member.dto.MemberUpdatePasswordRequestDto;
import com.ssafy.diary.domain.member.service.MemberService;
import com.ssafy.diary.global.constant.AuthType;
import com.ssafy.diary.global.exception.AlreadyExistsEmailException;
import com.ssafy.diary.global.exception.AlreadyExistsMemberException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.apache.coyote.BadRequestException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Member", description = "회원 API")
@RestController
@RequestMapping("/api/member")
@RequiredArgsConstructor
public class MemberController {
    final private MemberService memberService;

    @Operation(summary = "아이디 중복 확인", description = "아이디 및 이메일 중복 확인")
    @GetMapping("/check")
    public ResponseEntity<String> checkMemberOrEmailId(@RequestParam(name= "id",required = false) String id, @RequestParam(name = "email",required = false) String email) {
        boolean isIdEmpty=id==null||id.isEmpty();
        boolean isEmailEmpty=email==null||email.isEmpty();
        if(isIdEmpty&&isEmailEmpty) {
            return ResponseEntity.badRequest().body("value cannot be empty");
        }
        if(!isIdEmpty&&!isEmailEmpty) {
            return ResponseEntity.badRequest().body("only one value is allowed");
        }


        if (isEmailEmpty&&memberService.checkExistMemberId(id, AuthType.LOCAL)) {
            throw new AlreadyExistsMemberException("member ID " + id + "already is exists");
        }

        if(isIdEmpty&&memberService.checkExistEmail(email,AuthType.LOCAL)){
            throw new AlreadyExistsEmailException("email " + email + " is already exists");
        }
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "회원 가입", description = "회원 가입")
    @PostMapping("/register")
    public ResponseEntity<Object> authJoin(@RequestBody MemberRegisterRequestDto memberRegisterRequestDto) {
        memberService.registerMember(memberRegisterRequestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body("register successfully");
    }

    @Operation(summary = "회원 정보 조회", description = "회원 정보 조회")
    @GetMapping("/my")
    public ResponseEntity<MemberInfoResponseDto> memberInfo(@AuthenticationPrincipal PrincipalMember principalMember) {

        return ResponseEntity.ok().body(memberService.getMemberInfo(principalMember.getIndex()));
    }
    @Operation(summary = "회원 수정", description = "비밀번호 수정")
    @ApiResponse(responseCode = "200", description = "회원 수정 성공")
    @ApiResponse(responseCode = "404", description = "멤버를 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @PutMapping("/auth")
    public ResponseEntity<String> memberPasswordUpdate(@AuthenticationPrincipal PrincipalMember principalMember,
                                                       @RequestBody MemberUpdatePasswordRequestDto memberUpdatePasswordRequestDto) throws BadRequestException {
        if(!memberUpdatePasswordRequestDto.getMemberNewPassword().isEmpty() &&!memberUpdatePasswordRequestDto.getMemberOldPassword().isEmpty()) {
            memberService.updateMemberPassword(principalMember.getIndex(), memberUpdatePasswordRequestDto);

            return ResponseEntity.ok().body("member password updated successfully");
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("password is empty");
    }

    @PutMapping
    public ResponseEntity<String> memberInfoUpdate(@AuthenticationPrincipal PrincipalMember principalMember,
                                                   @RequestBody MemberInfoUpdateRequestDto memberInfoUpdateRequestDto) throws BadRequestException {
            memberService.updateMemberInfo(principalMember.getIndex(), memberInfoUpdateRequestDto);
            return ResponseEntity.ok().body("member info updated successfully");
    }
    @DeleteMapping
    public ResponseEntity<String> memberDelete(@AuthenticationPrincipal PrincipalMember principalMember) {
        memberService.deleteMember(principalMember.getIndex());
        return ResponseEntity.ok().body("member delete successfully");
    }
}
