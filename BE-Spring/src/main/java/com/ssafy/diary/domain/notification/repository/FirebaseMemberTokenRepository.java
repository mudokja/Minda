package com.ssafy.diary.domain.notification.repository;

import com.ssafy.diary.domain.notification.entity.FirebaseMemberToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;


public interface FirebaseMemberTokenRepository extends QueryFirebaseMemberTokenRepository, JpaRepository<FirebaseMemberToken, Long> {
    List<FirebaseMemberToken> findAllByMemberIndex(Long memberIndex);
}

