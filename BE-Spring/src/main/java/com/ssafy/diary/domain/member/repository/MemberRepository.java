package com.ssafy.diary.domain.member.repository;


import com.ssafy.diary.domain.member.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberRepository extends JpaRepository<Member, Long> {
}
