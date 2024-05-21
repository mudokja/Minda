package com.ssafy.diary.domain.auth.service;

import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.auth.dto.TokenInfoDto;
import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.global.util.JwtUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Collection;

/**
 * Oauth2 로그인 성공시 처리 핸들러 사용자 정의 구현
 *
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OAuth2LoginSuccessHandler implements AuthenticationSuccessHandler {

    private final JwtService jwtService;
    @Value("${app.baseurl.frontend}")
    private String frontendBaseurl;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
        log.info("OAuth2 Login 성공");
        try {
            Member oAuth2User = ((PrincipalMember) authentication.getPrincipal()).toEntity();
            log.debug(oAuth2User.toString());
            loginSuccess(response, authentication); // 로그인에 성공한 경우 access, refresh 토큰 생성
        } catch (Exception e) {

            log.debug("로그인 에러: {} 원인 :{}, {}",e.getMessage(),e.getCause(),e.getStackTrace());
        }
        log.info("로그인 절차 완료!");


    }

    private void loginSuccess(HttpServletResponse response, Authentication authentication) throws IOException, URISyntaxException {
        TokenInfoDto tokenInfo = jwtService.createToken(authentication);
        response.addHeader(JwtUtil.AUTHORIZATION_HEADER, JwtUtil.JWT_TYPE + tokenInfo.getAccessToken());

        URI cookieDomain=new URI(frontendBaseurl);

        Cookie cookie = new Cookie("refresh_token", tokenInfo.getRefreshToken());
        cookie.setHttpOnly(true);
        cookie.setMaxAge(JwtUtil.getRefreshTokenExpiredTime());
        cookie.setPath("/");
        cookie.setDomain(cookieDomain.getHost());
        cookie.setSecure(true); // https가 아니므로 아직 안됨
        response.addCookie(cookie);
        log.debug("토큰 :{}",tokenInfo.getAccessToken());
        UriComponents uriComponent= UriComponentsBuilder.fromHttpUrl(frontendBaseurl)
                .pathSegment("auth","login")
                .queryParam("resultCode",200)
                .queryParam("accessToken",tokenInfo.getAccessToken())
                .queryParam("refreshToken", tokenInfo.getRefreshToken())
                .encode()
                .build();
        response.sendRedirect(uriComponent.toString());

    }
}