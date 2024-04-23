package com.ssafy.diary.domain.member.service;

import com.ssafy.diary.domain.member.dto.MemberRegisterRequestDto;
import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.domain.member.repository.MemberRepository;
import com.ssafy.diary.global.constant.AuthType;
import com.ssafy.diary.global.constant.Role;
import com.ssafy.diary.global.exception.AlreadyExistsMemberException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MemberService {
    final private MemberRepository memberRepository;
    final private PasswordEncoder passwordEncoder;
    @Transactional
    public void registerMember(MemberRegisterRequestDto memberRegisterRequestDto) throws AlreadyExistsMemberException {

        boolean isExistsMember = checkExistMemberId(memberRegisterRequestDto.getId());

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
    public boolean checkExistMemberId(String memberId){
        return memberRepository.existsByIdAndPlatform(
                memberId, AuthType.LOCAL
        );
    }
}
