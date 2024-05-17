package com.ssafy.diary.domain.member.service;

import com.amazonaws.services.kms.model.NotFoundException;
import com.ssafy.diary.domain.member.dto.*;
import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.domain.member.repository.MemberRepository;
import com.ssafy.diary.domain.refreshToken.repository.RefreshTokenRepository;
import com.ssafy.diary.global.constant.AuthType;
import com.ssafy.diary.global.constant.Role;
import com.ssafy.diary.global.exception.AlreadyExistsEmailException;
import com.ssafy.diary.global.exception.AlreadyExistsMemberException;
import com.ssafy.diary.global.exception.MemberRegisterException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.coyote.BadRequestException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.pulsar.PulsarProperties;
import org.springframework.http.MediaType;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;

import java.io.Reader;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class MemberService {
    final private MemberRepository memberRepository;
    final private PasswordEncoder passwordEncoder;
    private final RefreshTokenRepository refreshTokenRepository;
    @Value("${app.oatuh2.kakao.unlink.key}")
    private String kakaoUnlinkKey;
    @Value("${app.oatuh2.kakao.unlink.url}")
    private String kakaoUnlinkUrl;
    @Value("${app.oatuh2.kakao.unlink.type}")
    private String kakaoUnlinkType;

    @Transactional
    public void updateMemberPassword(Long memberIndex, MemberUpdatePasswordRequestDto memberUpdatePasswordRequestDto) throws BadRequestException {
        Member member= getMemberCheck(memberIndex);
        if(!passwordEncoder.matches(memberUpdatePasswordRequestDto.getMemberOldPassword(),member.getPassword()))
        {
            throw new BadRequestException("member password incorrect");
        }
        member.setPassword(passwordEncoder.encode(memberUpdatePasswordRequestDto.getMemberNewPassword()));
    }
    @Transactional
    public void updateMemberInfo(Long memberIndex, MemberInfoUpdateRequestDto memberInfoUpdateRequestDto) throws NotFoundException {
        Member member= getMemberCheck(memberIndex);
        member.setNickname(memberInfoUpdateRequestDto.getMemberNickname());

    }
    @Transactional(readOnly = true)
    public Member getMemberCheck(Long memberIndex) {
        return memberRepository.findByIndex(memberIndex)
                .orElseThrow(() -> new UsernameNotFoundException("member not found"));
    }

    @Transactional
    public Member registerOauth2Member(MemberOauth2RegisterRequestDto memberOauth2RegisterRequestDto) throws AlreadyExistsMemberException, BadRequestException {

        boolean isExistsMember = checkExistMemberId(memberOauth2RegisterRequestDto.getId(), memberOauth2RegisterRequestDto.getPlatform());
        boolean isExistsEmail = checkExistEmail(memberOauth2RegisterRequestDto.getEmail(),  memberOauth2RegisterRequestDto.getPlatform());

        if (!isExistsMember&&!isExistsEmail) {
            try{

            Member member=memberRepository.save(
                    Member.builder()
                            .id(memberOauth2RegisterRequestDto.getId())
                            .role(Role.USER)
                            .platform(memberOauth2RegisterRequestDto.getPlatform())
                            .nickname(memberOauth2RegisterRequestDto.getNickname())
                            .email(memberOauth2RegisterRequestDto.getEmail())
                            .build()
            );
            return member;
            }catch (Exception e){

            log.debug("register failed : {}",e.getMessage());
                throw new MemberRegisterException("register failed");
            }
        }
        if(isExistsEmail) {
            throw new AlreadyExistsEmailException("email already exists");
        }
            return memberRepository.findByIdAndPlatform(memberOauth2RegisterRequestDto.getId(),memberOauth2RegisterRequestDto.getPlatform()).orElseThrow();
    }
    @Transactional
    public void registerMember(MemberRegisterRequestDto memberRegisterRequestDto) throws AlreadyExistsMemberException {

        boolean isExistsMember = checkExistMemberId(memberRegisterRequestDto.getId(), AuthType.LOCAL);
        boolean isExistsEmail = checkExistEmail(memberRegisterRequestDto.getEmail(), AuthType.LOCAL);
        if(isExistsMember) {
            throw new AlreadyExistsMemberException("member already exists");
        }
        if(isExistsEmail) {
            throw new AlreadyExistsEmailException("email already exists");
        }
        try {
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
        }catch (Exception e){
        log.debug("register failed : {}",e.getMessage());
        throw new MemberRegisterException("register failed");
    }
    }
    @Transactional(readOnly = true)
    public boolean checkExistMemberId(String memberId, AuthType platform){
        return memberRepository.existsByIdAndPlatform(
                memberId, platform
        );
    }
    public boolean checkExistEmail(String email, AuthType platform){
        return memberRepository.existsByEmailAndPlatform(
                email, platform
        );
    }
    @Transactional
    public void deleteMember(Long memberIndex){
        Member member= memberRepository.findByIndexAndIsDeletedFalse(memberIndex)
                .orElseThrow(()->new UsernameNotFoundException("member not found"));
        member.setIsDeleted(true);
        if(member.getPlatform().equals(AuthType.KAKAO)) {
            WebClient webClient
                    = WebClient.builder().baseUrl(kakaoUnlinkUrl).build();
            Map<String, Object> body = new HashMap<>();
            body.put("target_id_type","user_id");
            body.put("target_id",member.getIndex());
            webClient.post()
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .header("Authorization",kakaoUnlinkType+" "+kakaoUnlinkKey)
                    .bodyValue(body)
                    .retrieve()
                    .bodyToMono(Reader.class)
                    .doOnNext(response -> {
                        System.out.println("Response from External API: " + body);
                        // 받은 데이터 처리하는 로직
                    });
        }
        memberRepository.deleteById(memberIndex);
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
