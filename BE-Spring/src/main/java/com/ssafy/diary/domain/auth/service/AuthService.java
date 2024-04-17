package com.ssafy.diary.domain.auth.service;

import com.ssafy.diary.domain.auth.dto.LocalLoginRequestDto;
import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.auth.dto.TokenInfoDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final JwtService jwtService;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;

    public TokenInfoDto login(LocalLoginRequestDto loginRequestDto) {
        return createAuthenticationToken(loginRequestDto.getId(), loginRequestDto.getPassword());
    }

    public TokenInfoDto createAuthenticationToken(String memberId, String memberPassword) {

        UsernamePasswordAuthenticationToken authenticationToken =
                new UsernamePasswordAuthenticationToken(memberId, memberPassword);

        // authenticate 메소드가 실행이 될 때 CustomUserDetailsService class의 loadUserByUsername 메소드가 실행
        Authentication authentication = authenticationManagerBuilder.getObject().authenticate(authenticationToken);

        // 해당 객체를 SecurityContextHolder에 저장하고
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // authentication 객체를 createToken 메소드를 통해서 JWT Token을 생성
        TokenInfoDto tokenInfoDto = jwtService.createToken(authentication);

        jwtService.createAndSaveRefreshToken(((PrincipalMember) authentication.getPrincipal()).toEntity());

        return tokenInfoDto;
    }
}
