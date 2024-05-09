package com.ssafy.diary.domain.openAI.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class DallEResponseDto {
    private long created;
    private List<ImageData> data;

    public static class ImageData {
        @JsonProperty("revised_prompt")
        private String revisedPrompt;
        private String url;

        // getters and setters
        public String getRevisedPrompt() {
            return revisedPrompt;
        }

        public void setRevisedPrompt(String revisedPrompt) {
            this.revisedPrompt = revisedPrompt;
        }

        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }
    }

    // getters and setters
    public long getCreated() {
        return created;
    }

    public void setCreated(long created) {
        this.created = created;
    }

    public List<ImageData> getData() {
        return data;
    }

    public void setData(List<ImageData> data) {
        this.data = data;
    }
}