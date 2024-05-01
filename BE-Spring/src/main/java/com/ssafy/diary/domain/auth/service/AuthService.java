package com.ssafy.diary.domain.auth.service;

import com.ssafy.diary.domain.auth.dto.LocalLoginRequestDto;
import com.ssafy.diary.domain.auth.dto.Oauth2LoginRequestDto;
import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.auth.dto.TokenInfoDto;
import com.ssafy.diary.domain.member.dto.MemberOauth2RegisterRequestDto;
import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.domain.member.service.MemberService;
import com.ssafy.diary.global.constant.Role;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.EnumUtils;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.Collection;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final JwtService jwtService;
    private final MemberService memberService;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;

    public TokenInfoDto login(LocalLoginRequestDto loginRequestDto) {
        return createAuthenticationToken(loginRequestDto.getId(), loginRequestDto.getPassword());
    }
    @Transactional
    public TokenInfoDto oauth2Login(Oauth2LoginRequestDto oauth2LoginRequestDto){
        boolean memberExist =memberService.checkExistMemberId(oauth2LoginRequestDto.getId(),oauth2LoginRequestDto.getPlatform());
        Member member=null;
        Long memberIndex=-1L;
        if(!memberExist){
            member=memberService.registerOauth2Member(MemberOauth2RegisterRequestDto.builder()
                            .id(oauth2LoginRequestDto.getId())
                            .platform(oauth2LoginRequestDto.getPlatform())
                            .nickname(oauth2LoginRequestDto.getNickname())
                            .email(oauth2LoginRequestDto.getEmail())
                    .build());
        }else{
        member =memberService.getMemberCheck(memberIndex);

        }
        Collection<? extends GrantedAuthority> authorities =
                Arrays.stream(member.getRole().toString().split(","))
                        .map((role)-> EnumUtils.isValidEnum(Role.class, role)?new SimpleGrantedAuthority("ROLE_".concat(role)):new SimpleGrantedAuthority(role))
                        .toList();
        return createAuthenticationToken(member,authorities);
    }
    public TokenInfoDto createAuthenticationToken(String memberId, String memberPassword) {

        UsernamePasswordAuthenticationToken authenticationToken =
                new UsernamePasswordAuthenticationToken(memberId, memberPassword);

        // authenticate 메소드가 실행이 될 때 CustomUserDetailsService class의 loadUserByUsername 메소드가 실행
        Authentication authentication = authenticationManagerBuilder.getObject().authenticate(authenticationToken);

        // 해당 객체를 SecurityContextHolder에 저장하고
        SecurityContextHolder.getContext().setAuthentication(authentication);


        return jwtService.createToken(authentication);
    }
    public TokenInfoDto createAuthenticationToken(Member oAuth2User, Collection<? extends GrantedAuthority> authorities) {
        PrincipalMember principal = PrincipalMember.builder()
                .member(oAuth2User)
                .build();

        Authentication authentication = new OAuth2AuthenticationToken(principal, authorities, oAuth2User.getPlatform().toString());


        SecurityContextHolder.getContext().setAuthentication(authentication);


        return jwtService.createToken(authentication);
    }
}
