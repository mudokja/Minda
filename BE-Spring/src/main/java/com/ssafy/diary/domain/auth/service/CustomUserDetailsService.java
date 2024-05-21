package com.ssafy.diary.domain.auth.service;

import com.ssafy.diary.domain.auth.dto.PrincipalMember;
import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.domain.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class CustomUserDetailsService implements UserDetailsService {
    private final MemberRepository memberRepository;
    private PasswordEncoder passwordEncoder;

    @Override
    public UserDetails loadUserByUsername(String memberId) throws UsernameNotFoundException {
        Member member=memberRepository.findById(memberId).orElseThrow(()-> new UsernameNotFoundException("사용자를 찾을 수 없습니다."));
        PrincipalMember userDetail= PrincipalMember.builder()
                .member(member)
                .build();
        return userDetail;

    }
}