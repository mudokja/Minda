package com.ssafy.diary.domain.member.repository;


import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.global.constant.AuthType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Long> {
    Optional<Member> findByIdAndPlatform(String memberId, AuthType platform);

    Optional<Member> findById(String memberId);

    Optional<Member> findByIndex(Long memberIndex);

    boolean existsByIdAndPlatform(String id, AuthType authType);
}
