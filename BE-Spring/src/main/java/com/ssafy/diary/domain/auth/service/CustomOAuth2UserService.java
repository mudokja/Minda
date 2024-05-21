package com.ssafy.diary.domain.auth.service;


import com.ssafy.diary.domain.auth.dto.KakaoUserInfo;
import com.ssafy.diary.domain.auth.dto.NaverUserInfo;
import com.ssafy.diary.domain.auth.dto.OAuth2UserInfo;
import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.domain.member.repository.MemberRepository;
import com.ssafy.diary.global.constant.AuthType;
import com.ssafy.diary.global.constant.Role;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {
    private final MemberRepository memberRepository;
    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        OAuth2UserInfo oAuth2UserInfo =switch (userRequest.getClientRegistration().getRegistrationId()){
            case "naver" -> new NaverUserInfo((Map)oAuth2User.getAttributes().get("response"));
            case "kakao" -> new KakaoUserInfo((Map)oAuth2User.getAttributes().get("kakao_account"),
                    String.valueOf(oAuth2User.getAttributes().get("id")));
            default -> null;
        };
        String memberId = oAuth2UserInfo.getProviderId();
        String memberEmail= oAuth2UserInfo.getEmail();
        String memberNickname = oAuth2UserInfo.getNickname();
        String memberProfileImageUrl= oAuth2UserInfo.getProfileImageUrl();
        AuthType snsType= switch (oAuth2UserInfo.getProvider()){
            case "naver" -> AuthType.NAVER;
            case "kakao" -> AuthType.KAKAO;
            default -> throw new RuntimeException("소셜로그인 Provider 에러");
        };
        log.debug("providerId {}, Objet : {}",memberId, oAuth2UserInfo.toString());
        Member member = memberRepository.findByIdAndPlatform(memberId,snsType).orElse(
                null
        );


        if(member==null){
            member=Member.builder()
                    .id(memberId)
                    .platform(snsType)
                    .role(Role.USER)
                    .nickname(memberNickname)
                    .profileImage(memberProfileImageUrl)
                    .email(memberEmail)
                .build();

            memberRepository.save(member);


        }
        return PrincipalMember.builder()
                .member(member)
                .attributes(oAuth2User.getAttributes())
                .build();
    }

}