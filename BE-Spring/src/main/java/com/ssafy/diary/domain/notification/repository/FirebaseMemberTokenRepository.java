package com.ssafy.diary.domain.notification.repository;

import com.ssafy.diary.domain.notification.entity.FirebaseMemberToken;
import com.ssafy.diary.global.constant.FireBasePlatform;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;


public interface FirebaseMemberTokenRepository extends QueryFirebaseMemberTokenRepository, JpaRepository<FirebaseMemberToken, Long> {
    List<FirebaseMemberToken> findAllByMemberIndex(Long memberIndex);

    void deleteByMemberIndexAndFireBasePlatform(Long memberIndex, FireBasePlatform firebasePlatform);

    void deleteByFireBaseToken(String fireBaseToken);

    boolean existsByFireBaseToken(String token);
}

