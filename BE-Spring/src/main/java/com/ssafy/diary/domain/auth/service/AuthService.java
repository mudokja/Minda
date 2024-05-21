package com.ssafy.diary.domain.auth.service;

import com.ssafy.diary.domain.auth.dto.LocalLoginRequestDto;
import com.ssafy.diary.domain.auth.dto.Oauth2LoginRequestDto;
import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.auth.dto.TokenInfoDto;
import com.ssafy.diary.domain.member.dto.MemberOauth2RegisterRequestDto;
import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.domain.member.repository.MemberRepository;
import com.ssafy.diary.domain.member.service.MemberService;
import com.ssafy.diary.global.constant.Role;
import com.ssafy.diary.global.exception.EmailException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.EnumUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.coyote.BadRequestException;
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
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final JwtService jwtService;
    private final MemberService memberService;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final MemberRepository memberRepository;

    public TokenInfoDto login(LocalLoginRequestDto loginRequestDto) {
        return createAuthenticationToken(loginRequestDto.getId(), loginRequestDto.getPassword());
    }

    public TokenInfoDto oauth2Login(Oauth2LoginRequestDto oauth2LoginRequestDto) throws BadRequestException {
        Optional<Member> memberEntity =memberRepository.findByIdAndPlatform(oauth2LoginRequestDto.getId(),oauth2LoginRequestDto.getPlatform());
        Member member = null;
        if(memberEntity.isEmpty()){
            if(StringUtils.isBlank(oauth2LoginRequestDto.getEmail())){
                throw new EmailException.EmailNotValidEmail("email is empty");
            }
            member =memberService.registerOauth2Member(MemberOauth2RegisterRequestDto.builder()
                            .id(oauth2LoginRequestDto.getId())
                            .platform(oauth2LoginRequestDto.getPlatform())
                            .nickname(oauth2LoginRequestDto.getNickname())
                            .email(oauth2LoginRequestDto.getEmail())
                    .build());
        }else{

        member=memberEntity.get();
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
