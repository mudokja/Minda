package com.ssafy.diary.domain.member.service;

import com.amazonaws.services.kms.model.NotFoundException;
import com.ssafy.diary.domain.member.dto.MemberInfoResponseDto;
import com.ssafy.diary.domain.member.dto.MemberModifyRequestDto;
import com.ssafy.diary.domain.member.dto.MemberOauth2RegisterRequestDto;
import com.ssafy.diary.domain.member.dto.MemberRegisterRequestDto;
import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.domain.member.repository.MemberRepository;
import com.ssafy.diary.global.constant.AuthType;
import com.ssafy.diary.global.constant.Role;
import com.ssafy.diary.global.exception.AlreadyExistsMemberException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.coyote.BadRequestException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class MemberService {
    final private MemberRepository memberRepository;
    final private PasswordEncoder passwordEncoder;

    @Transactional
    public void updateMemberPassword(Long memberIndex, MemberModifyRequestDto memberModifyRequestDto) throws BadRequestException {
        Member member= getMemberCheck(memberIndex);
        if(!passwordEncoder.matches(member.getPassword(),memberModifyRequestDto.getMemberOldPassword()))
        {
            throw new BadRequestException("member password incorrect");
        }
        member.setPassword(passwordEncoder.encode(memberModifyRequestDto.getMemberNewPassword()));
    }

    public void updateMemberInfo(Long memberIndex, MemberModifyRequestDto memberModifyRequestDto) throws NotFoundException {
        Member member= getMemberCheck(memberIndex);
        member.setNickname(member.getNickname());
    }
    @Transactional(readOnly = true)
    public Member getMemberCheck(Long memberIndex) {
        return memberRepository.findByIndex(memberIndex)
                .orElseThrow(() -> new UsernameNotFoundException("member not found"));
    }

    @Transactional
    public Member registerOauth2Member(MemberOauth2RegisterRequestDto memberOauth2RegisterRequestDto) throws AlreadyExistsMemberException {

        boolean isExistsMember = checkExistMemberId(memberOauth2RegisterRequestDto.getId(), AuthType.KAKAO);

        if (!isExistsMember) {
            Member member=memberRepository.save(
                    Member.builder()
                            .id(memberOauth2RegisterRequestDto.getId())
                            .role(Role.USER)
                            .platform(memberOauth2RegisterRequestDto.getPlatform())
                            .nickname(memberOauth2RegisterRequestDto.getNickname())
                            .email(memberOauth2RegisterRequestDto.getEmail())
                            .build()
            );
            log.debug("등록 결과 {}",member.getIndex());
            return member;
        }
            return memberRepository.findById(memberOauth2RegisterRequestDto.getId()).orElseThrow();
    }
    @Transactional
    public void registerMember(MemberRegisterRequestDto memberRegisterRequestDto) throws AlreadyExistsMemberException {

        boolean isExistsMember = checkExistMemberId(memberRegisterRequestDto.getId(), AuthType.LOCAL);

        if (!isExistsMember) {
            memberRepository.save(
                    Member.builder()
                            .id(memberRegisterRequestDto.getId())
                            .role(Role.USER)
                            .platform(AuthType.LOCAL)
                            .nickname(memberRegisterRequestDto.getNickname())
                            .email(memberRegisterRequestDto.getEmail())
                            .password(passwordEncoder.encode(memberRegisterRequestDto.getPassword()))
                            .build()
            );
        }
        if(isExistsMember){
            throw new AlreadyExistsMemberException("member ID "+memberRegisterRequestDto.getId()+ " is exists");
        }
    }
    @Transactional(readOnly = true)
    public boolean checkExistMemberId(String memberId, AuthType platform){
        return memberRepository.existsByIdAndPlatform(
                memberId, platform
        );
    }

    public MemberInfoResponseDto getMemberInfo(Long memberIndex){
        Member member = getMemberCheck(memberIndex);

        return MemberInfoResponseDto.builder()
                .memberEmail(member.getEmail())
                .memberNickname(member.getNickname())
                .memberId(member.getId())
                .build();
    }
    
}
