package com.ssafy.diary.domain.auth.service;

import com.ssafy.diary.domain.auth.dto.MemberInfoDto;
import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.auth.dto.TokenInfoDto;
import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.domain.member.repository.MemberRepository;
import com.ssafy.diary.domain.refreshToken.entity.RefreshToken;
import com.ssafy.diary.domain.refreshToken.repository.RefreshTokenRepository;
import com.ssafy.diary.global.constant.AuthType;
import com.ssafy.diary.global.constant.Role;
import com.ssafy.diary.global.util.JwtUtil;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.EnumUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.stream.Collectors;

/**
 * 토큰 관련 메소드 제공 유틸, 서비스 클래스
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class JwtService {
    @Value("${jwt-config.secret}")
    private String secretKey;

    @Value("${JWT-TIME-ZONE:Asia/Seoul}")
    public String TIME_ZONE;

    private final RefreshTokenRepository tokenRepository;
    private final MemberRepository memberRepository;


    private Key key;
    private final long refreshTokenExpiredTime =JwtUtil.getRefreshTokenExpiredTime();
    private final long accessTokenExpiredTime= JwtUtil.getAccessTokenExpiredTime();

    @PostConstruct
    private void init() {
        byte[] keyBytes = this.secretKey.getBytes(StandardCharsets.UTF_8);
        this.key= Keys.hmacShaKeyFor(keyBytes);
    }

    public TokenInfoDto createToken(Authentication authentication) {
        Member member = ((PrincipalMember) authentication.getPrincipal()).toEntity();
        Collection<GrantedAuthority> roles = new ArrayList<>();
        roles.add(new SimpleGrantedAuthority(member.getRole().toString()));
        String accessToken= createAccessToken(member.getIndex(),roles,member.getPlatform());

        String refreshToken= createAndSaveRefreshToken(member.toMemberInfoDto());

        return TokenInfoDto.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }




    public String createAccessToken(Long memberIndex, Collection<? extends GrantedAuthority> authorities, AuthType platform) throws EntityNotFoundException {
        if(memberIndex==null){
            throw new EntityNotFoundException();
        }

        String authoritiesString = authorities.stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.joining(","));
        LocalDateTime now = LocalDateTime.now(ZoneId.of(TIME_ZONE));
        Member member= memberRepository.findById(memberIndex).orElseThrow(()->new RuntimeException(""));
        return Jwts.builder()
                .subject("access_token")
                .claim("memberIndex",member.getIndex().toString())
                .claim("memberNickName",member.getNickname())
                .issuedAt(Date.from(now.atZone(ZoneId.of(TIME_ZONE)).toInstant()))
                .claim("hasGrade", authoritiesString)
                .claim("platform",platform)
                .expiration(Date.from(now.plusSeconds(accessTokenExpiredTime).atZone(ZoneId.of(TIME_ZONE)).toInstant())) // set Expire Time
                .signWith(key)
                .compact();
    }


    public String createRefreshToken(String memberIndex) {

        LocalDateTime now = LocalDateTime.now(ZoneId.of(TIME_ZONE));

        return Jwts.builder()
                .subject("refreshToken")
                .claim("memberIndex",memberIndex)
                .issuedAt(Date.from(now.atZone(ZoneId.of(TIME_ZONE)).toInstant()))
                .expiration(Date.from(now.plusSeconds(refreshTokenExpiredTime).atZone(ZoneId.of(TIME_ZONE)).toInstant())) // set Expire Time
                .signWith(key)
                .compact();
    }

    // 토큰에서 회원 정보 추출
    public Claims parseClaims(String token) {
        return Jwts.parser().verifyWith((SecretKey) key).build().parseSignedClaims(token).getPayload();
    }

    // JWT 토큰에서 인증 정보 조회
    public Authentication getAuthentication(String token) {
        Claims claims = parseClaims(token);

        Collection<? extends GrantedAuthority> authorities =
                Arrays.stream(claims.get("hasGrade").toString().split(","))
                        .map((role)-> EnumUtils.isValidEnum(Role.class, role)?new SimpleGrantedAuthority("ROLE_".concat(role)):new SimpleGrantedAuthority(role))
                        .collect(Collectors.toList());

        switch (AuthType.valueOf(claims.get("platform").toString())) {
            case GUEST -> {
                PrincipalMember principal = PrincipalMember.builder()
                        .member(Member.builder()
                                .nickname("GUEST")
                                .platform(AuthType.GUEST)
                                .role(Role.valueOf(claims.get("hasGrade").toString()))
                                .build()
                        )
                        .build();
                return new OAuth2AuthenticationToken(principal, authorities, claims.get("platform").toString());
            }
            case LOCAL -> {
                PrincipalMember principal = PrincipalMember.builder()
                        .member(Member.builder()
                                .index(Long.valueOf(claims.get("memberIndex").toString()))
                                .nickname(claims.get("memberNickName").toString())
                                .role(Role.valueOf(claims.get("hasGrade").toString()))
                                .platform(AuthType.valueOf(claims.get("platform").toString()))
                                .build()
                        )
                        .build();
                return new UsernamePasswordAuthenticationToken(principal,token,authorities);
            }
            case KAKAO,NAVER -> {
                PrincipalMember principal = PrincipalMember.builder()
                        .member(Member.builder()
                                .index(Long.valueOf(claims.get("memberIndex").toString()))
                                .nickname(claims.get("memberNickName").toString())
                                .role(Role.valueOf(claims.get("hasGrade").toString()))
                                .platform(AuthType.valueOf(claims.get("platform").toString()))
                                .build()
                        )
                        .build();

                return new OAuth2AuthenticationToken(principal, authorities, claims.get("platform").toString());
            }
        }
        return null;

    }

    public boolean validateAccessToken(String token) {
        try {
            Claims claims = parseClaims(token);
            return !claims.getExpiration().before(new Date());

        } catch (io.jsonwebtoken.security.SecurityException | MalformedJwtException e) {
            log.info("잘못된 JWT 서명입니다.");
        }
//        catch (ExpiredJwtException e) {
//            log.info("만료된 JWT 토큰입니다.");
//        }
        catch (UnsupportedJwtException e) {
            log.info("지원되지 않는 JWT 토큰입니다.");
        } catch (IllegalArgumentException e) {
            log.info("JWT 토큰이 잘못되었습니다.");
        }
        return false;
    }

    public boolean validateRefreshToken(String token) {
        try {
            Claims claims = parseClaims(token);
            return !claims.getExpiration().before(new Date());
        } catch (io.jsonwebtoken.security.SecurityException | MalformedJwtException e) {
            log.error("오류 내용 {} : aaa {}",e.getMessage(),e.toString());
            log.info("잘못된 JWT 서명입니다.");
        } catch (ExpiredJwtException e) {

            log.info("만료된 JWT 토큰입니다.");

        } catch (UnsupportedJwtException e) {

            log.info("지원되지 않는 JWT 토큰입니다.");
        } catch (IllegalArgumentException e) {

            log.info("JWT 토큰이 잘못되었습니다.");
        }
        return false;
    }

    public RefreshToken findRefreshToken(String refreshToken) {
        try {
            log.debug("토큰 값 {}",refreshToken);
            return tokenRepository.findById(refreshToken).orElseThrow(()->new RuntimeException("존재하지 않는 리프레시 토큰"));
        } catch (Exception e) {

            log.info("refreshToken finder error : {}",e.getMessage());
        }
        return null;

    }


    public String createAndSaveRefreshToken(MemberInfoDto member) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of(TIME_ZONE));
        LocalDateTime expireTime=now.plusSeconds(refreshTokenExpiredTime);
        String refreshToken= Jwts.builder()
                .subject("refreshToken")
                .claim("memberIndex",member.getIndex().toString())
                .issuedAt(Date.from(now.atZone(ZoneId.of(TIME_ZONE)).toInstant()))
                .expiration(Date.from(expireTime.atZone(ZoneId.of(TIME_ZONE)).toInstant())) // set Expire Time
                .signWith(key)
                .compact();


        tokenRepository.save(RefreshToken.builder()
                .refreshToken(refreshToken)
                .platform(member.getPlatform())
                .memberIndex(member.getIndex())
                .role(member.getRole())
                .regDate(LocalDateTime.now())
                .expireTime(refreshTokenExpiredTime)
                .build()
        );
        return refreshToken;
    }

    public String createGuestAccessToken(String guestMemberName, Collection<? extends GrantedAuthority> authorities, AuthType platform) {
        String authoritiesString = authorities.stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.joining(","));
        LocalDateTime now = LocalDateTime.now(ZoneId.of(TIME_ZONE));
        return Jwts.builder()
                .subject("access_token")
                .claim("memberNickName",guestMemberName)
                .issuedAt(Date.from(now.atZone(ZoneId.of(TIME_ZONE)).toInstant()))
                .claim("hasGrade", authoritiesString)
                .claim("platform",platform)
                .expiration(Date.from(now.plusSeconds(accessTokenExpiredTime).atZone(ZoneId.of(TIME_ZONE)).toInstant())) // set Expire Time
                .signWith(key)
                .compact();
    }
}

