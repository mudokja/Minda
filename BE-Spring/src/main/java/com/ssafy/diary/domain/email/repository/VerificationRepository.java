package com.ssafy.diary.domain.email.repository;

import com.ssafy.diary.domain.email.entity.VerificationCode;
import org.springframework.data.repository.CrudRepository;

public interface VerificationRepository extends CrudRepository<VerificationCode, String> {

}
