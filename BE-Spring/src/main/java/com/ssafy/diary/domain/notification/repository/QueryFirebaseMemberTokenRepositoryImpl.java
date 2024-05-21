package com.ssafy.diary.domain.notification.repository;

import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class QueryFirebaseMemberTokenRepositoryImpl implements QueryFirebaseMemberTokenRepository {
    private final JPAQueryFactory queryFactory;

}
