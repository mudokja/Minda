package com.ssafy.diary.domain.analyze.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import lombok.Builder;
import lombok.Data;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.HashMap;
import java.util.List;

@Document(collection = "analyze")
@Data
@Builder
public class Analyze {
    @Id
    @Field(name="diary_index")
    private Long diaryIndex;
    private String[] sentence;
    private HashMap<String,Double[]> emotion;
    private HashMap<String,Double> keyword;
}
