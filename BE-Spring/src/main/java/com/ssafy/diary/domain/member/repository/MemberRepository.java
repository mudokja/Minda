package com.ssafy.diary.domain.member.repository;


import com.ssafy.diary.domain.member.entity.Member;
import com.ssafy.diary.global.constant.AuthType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Long> {
    Optional<Member> findByIdAndPlatform(String memberId, AuthType platform);

    Optional<Member> findById(String memberId);

    Optional<Member> findByIndex(Long memberIndex);

    Boolean existsByIdAndPlatform(String id, AuthType authType);
    Optional<Member> findByIndexAndIsDeletedFalse(Long index);

    Boolean existsByEmailAndPlatform(String email, AuthType platform);

//    List<Member> findByIndexAndIsDeletedTrueAndModDateBefore(LocalDateTime isDeleted);
}
