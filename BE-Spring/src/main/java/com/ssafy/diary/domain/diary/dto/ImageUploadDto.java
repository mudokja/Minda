package com.ssafy.diary.domain.diary.dto;

import org.springframework.web.multipart.MultipartFile;
import lombok.Getter;
import lombok.Setter;
import java.util.List;

@Getter
@Setter
public class ImageUploadDto {

    private List<MultipartFile> files;

}
