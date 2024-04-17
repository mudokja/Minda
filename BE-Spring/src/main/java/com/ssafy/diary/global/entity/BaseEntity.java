package com.ssafy.diary.global.entity;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;

import java.time.LocalDateTime;

@MappedSuperclass
public abstract class BaseEntity {

    @CreatedDate
    @Column(name = "reg_date")
    private LocalDateTime regDate;

    @LastModifiedDate
    @Column(name = "mod_date")
    private LocalDateTime modDate;

    @Column(name = "is_deleted")
    private String isDeleted;

}
