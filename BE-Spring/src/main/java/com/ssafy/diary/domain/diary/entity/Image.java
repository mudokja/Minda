package com.ssafy.diary.domain.diary.entity;

import com.ssafy.diary.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Getter
public class Image {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "image_index")
    private Long imageIndex;

//    @Column(name = "diary_index")
//    private Long diaryIndex;

    @Column(name = "image_name")
    private String imageName;

    @Column(name = "image_link")
    private String imageLink;
}
