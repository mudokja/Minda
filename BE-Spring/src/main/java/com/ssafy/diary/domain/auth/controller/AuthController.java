package com.ssafy.diary.domain.auth.controller;

import com.ssafy.diary.domain.auth.dto.*;
import com.ssafy.diary.domain.auth.service.AuthService;
import com.ssafy.diary.domain.auth.service.JwtService;
import com.ssafy.diary.domain.member.dto.MemberOauth2RegisterRequestDto;
import com.ssafy.diary.domain.member.service.MemberService;
import com.ssafy.diary.domain.refreshToken.entity.RefreshToken;
import com.ssafy.diary.domain.refreshToken.repository.RefreshTokenRepository;
import com.ssafy.diary.global.util.JwtUtil;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.coyote.BadRequestException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@Slf4j
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final JwtService jwtService;
    private final RefreshTokenRepository refreshTokenRepository;

    @Value("${app.baseurl.frontend}")
    private String frontendBaseurl;

//

    @PostMapping("/login")
    public ResponseEntity<TokenInfoDto> authLogin(@RequestBody LocalLoginRequestDto loginRequestDto, HttpServletResponse response) {
        log.debug("인증 시작");

        TokenInfoDto tokenInfoDto = authService.login(loginRequestDto);

        Cookie cookie = new Cookie("refresh_token", tokenInfoDto.getRefreshToken());
        cookie.setHttpOnly(true);
        cookie.setMaxAge(JwtUtil.getRefreshTokenExpiredTime());
        cookie.setPath("/");
        cookie.setSecure(true);
        response.addCookie(cookie);

        return ResponseEntity.ok(tokenInfoDto);
    }



    @DeleteMapping("/logout")
    public ResponseEntity<?> logout(@RequestParam String refreshToken) {
        refreshTokenRepository.delete(RefreshToken.builder().refreshToken(refreshToken).build());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/oauth2/login")
    public ResponseEntity<TokenInfoDto> authOauth2Login(@RequestBody Oauth2LoginRequestDto oauth2LoginRequestDto) throws BadRequestException {

        return ResponseEntity.ok().body(authService.oauth2Login(oauth2LoginRequestDto));
    }

    @PostMapping("/refresh")
    public ResponseEntity<?> requestAccessToken(HttpServletResponse response, HttpServletRequest request,@RequestBody RefreshTokenRequestDto refreshTokenDto) {
        log.debug("엑세스토큰 재발급");
        String refreshTokenString = refreshTokenDto.getRefreshToken();
        if (!StringUtils.hasText(refreshTokenString)) {
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("refresh_token".equals(cookie.getName())) {
                        refreshTokenString = cookie.getValue();
                    }
                }
            }
        }
            log.debug("토큰 {}",refreshTokenString);
            if (StringUtils.hasText(refreshTokenString)
                    && jwtService.validateRefreshToken(refreshTokenString)) {
                RefreshToken refreshToken = jwtService.findRefreshToken(refreshTokenString);
                if(refreshToken==null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
                AccessTokenDto accessTokenDto = AccessTokenDto.builder()
                        .accessToken(jwtService.createAccessToken(refreshToken.getMemberIndex(), List.of(() -> refreshToken.getRole().toString()), refreshToken.getPlatform()))
                        .build();
                response.setHeader(JwtUtil.AUTHORIZATION_HEADER, accessTokenDto.getAccessToken());
                return ResponseEntity.ok(accessTokenDto);
            }
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }


}
