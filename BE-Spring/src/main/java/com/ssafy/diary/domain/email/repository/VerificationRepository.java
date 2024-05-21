package com.ssafy.diary.domain.email.repository;

import com.ssafy.diary.domain.email.entity.VerificationCode;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.Optional;

public interface VerificationRepository extends CrudRepository<VerificationCode, String> {
    Optional<VerificationCode> findByCode(String email);
    List<VerificationCode> findByEmail(String email);
}
