package com.ssafy.diary.domain.diary.entity;

import com.ssafy.diary.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class Image {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "image_index")
    private Long imageIndex;

    @Column(name = "image_name")
    private String imageName;

    @Column(name = "image_link")
    private String imageLink;

    @Builder
    public Image(String imageName, String imageLink) {
        this.imageName = imageName;
        this.imageLink = imageLink;
    }
}
