package com.ssafy.diary.domain.s3.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.ssafy.diary.domain.diary.entity.Image;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class S3Service {
    private final AmazonS3 amazonS3;

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    public String saveImageFromUrl(String imageUrl) throws IOException {
        URL url = new URL(imageUrl);

        try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
            HttpGet httpGet = new HttpGet(url.toURI());
            try (CloseableHttpResponse response = httpClient.execute(httpGet)) {
                int statusCode = response.getStatusLine().getStatusCode();
                if (statusCode != 200) {
                    throw new IOException("Failed to download image, HTTP status code: " + statusCode);
                }

                HttpEntity entity = response.getEntity();
                if (entity == null) {
                    throw new IOException("No image content found at the URL.");
                }

                try (InputStream inputStream = entity.getContent()) {
                    ObjectMetadata metadata = new ObjectMetadata();
                    metadata.setContentLength(entity.getContentLength());
                    metadata.setContentType(entity.getContentType().getValue());

                    UUID uuid = UUID.randomUUID();
                    String key = uuid.toString();

                    String contentType = entity.getContentType().getValue();
                    int typeIndex = contentType.lastIndexOf("/") + 1;
                    contentType = contentType.substring(typeIndex);

                    key += "." + contentType;

                    amazonS3.putObject(bucket, key, inputStream, metadata);
                    return amazonS3.getUrl(bucket, key).toString();
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to download or upload image", e);
        }
    }

    public String saveFile(MultipartFile multipartFile) throws IOException {
        String originalFilename = multipartFile.getOriginalFilename();
        String type = originalFilename.substring(originalFilename.lastIndexOf("."));

//        // 파일이 이미 S3에 업로드되어 있는지 확인
//        if (isFileExists(originalFilename)) {
//            return getExistingFileUrl(originalFilename);
//        }

        UUID uuid = UUID.randomUUID();
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(multipartFile.getSize());
        metadata.setContentType(multipartFile.getContentType());

        amazonS3.putObject(bucket, uuid.toString() + type, multipartFile.getInputStream(), metadata);
        return amazonS3.getUrl(bucket, uuid.toString() + type).toString();
    }

    public void deleteFile(String originalFilename) {
        amazonS3.deleteObject(bucket, originalFilename);
    }

    //이미지 s3에 저장하고 imageList 반환
    public List<Image> saveAndGetImageList(MultipartFile[] imageFiles) {
        List<Image> imageList = new ArrayList<>();
        for (MultipartFile imageFile : imageFiles) {
            try {
                String imageLink = saveFile(imageFile);
                imageList.add(Image.builder()
                        .imageName(imageFile.getOriginalFilename())
                        .imageLink(imageLink)
                        .build());
            } catch (IOException e) {
                throw new RuntimeException(e);
            }

        }

        return imageList;
    }

    //이미지url에서 파일이름 추출해서 삭제
    public void deleteImageFromS3(String imageLink) {
        if (imageLink != null) {
            int lastSlashIndex = imageLink.lastIndexOf('/');
            if (lastSlashIndex != -1) {
                String imageName = imageLink.substring(lastSlashIndex + 1);
                deleteFile(imageName);
            }
        }
    }

    //이미지 리스트의 이미지url에서 파일이름 추출해서 삭제
    public void deleteImagesFromS3(List<Image> imageList) {
        for (Image image : imageList) {
            deleteImageFromS3(image.getImageLink());
        }

    }

//    // 파일이 이미 S3에 존재하는지 확인
//    private boolean isFileExists(String originalFilename) {
//        return amazonS3.doesObjectExist(bucket, originalFilename);
//    }
//
//    // 이미 S3에 업로드된 파일의 URL을 반환
//    private String getExistingFileUrl(String originalFilename) {
//        return amazonS3.getUrl(bucket, originalFilename).toString();
//    }
}
