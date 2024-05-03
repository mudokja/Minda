package com.ssafy.diary.global.config;

import org.apache.http.HttpHeaders;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class WebClientConfig {

//    @Bean
//    public WebClient.Builder webClientBuilder() {
//        return WebClient.builder()
//                .baseUrl("http://example.com")
//                .defaultHeader("Some-Header", "Value");
//        // 기타 필요한 설정
//    }

    @Bean
    public WebClient webClient() {
        return WebClient.builder()
                .baseUrl("https://k10b205.p.ssafy.io/api/ai")
                .defaultHeader(HttpHeaders.CONTENT_TYPE, "application/json")
                .build();
        // 기타 필요한 설정
    }

}
