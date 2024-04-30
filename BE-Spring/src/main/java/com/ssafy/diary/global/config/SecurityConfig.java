package com.ssafy.diary.global.config;

import com.ssafy.diary.domain.auth.service.CustomOAuth2UserService;
import com.ssafy.diary.domain.auth.service.JwtService;
import com.ssafy.diary.domain.auth.service.OAuth2LoginFailHandler;
import com.ssafy.diary.domain.auth.service.OAuth2LoginSuccessHandler;
import com.ssafy.diary.global.exception.CustomAccessDeniedHandler;
import com.ssafy.diary.global.exception.CustomAuthenticationEntryPoint;
import com.ssafy.diary.global.filter.JwtFilter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.FormLoginConfigurer;
import org.springframework.security.config.annotation.web.configurers.HttpBasicConfigurer;
import org.springframework.security.config.annotation.web.oauth2.login.TokenEndpointDsl;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import java.security.SecureRandom;
import java.util.List;

@Configuration
@EnableWebSecurity //시큐리티 활성화 -> 기본 스프링 필터 체인에 등록
@RequiredArgsConstructor
@Slf4j
public class SecurityConfig {

    private final CustomOAuth2UserService customOAuth2UserService;
    private final OAuth2LoginSuccessHandler oAuth2LoginSuccessHandler;
    private final OAuth2LoginFailHandler oAuth2LoginFailHandler;
    private final JwtService jwtService;
    private final CorsConfig corsConfig;
    private static final String[] PERMIT_PATTERNS = List.of(
            "/login","/favicon.ico"
    ).toArray(String[]::new);
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(8+new SecureRandom().nextInt(3));
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .httpBasic(HttpBasicConfigurer::disable)
                .sessionManagement((session) -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .csrf(AbstractHttpConfigurer::disable)
                .formLogin((FormLoginConfigurer::disable))
                .cors((customCorsConfig) -> customCorsConfig.configurationSource(corsConfig.corsConfigurationSource()))

                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(PERMIT_PATTERNS).permitAll()
                        .requestMatchers("/swagger-ui.html", "/swagger-ui/**", "/v3/api-docs/**", "/swagger-resources/**", "/webjars/**","/").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/member/check").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/member/register", "/api/auth/refresh", "/api/auth/login","/api/email/verification","/api/email/auth").permitAll()
                        .requestMatchers("/api/**").hasAnyRole("ADMIN", "USER")
                        .anyRequest().authenticated())
                .formLogin(AbstractHttpConfigurer::disable)

                .oauth2Login((oauth2) -> oauth2
                        .successHandler(oAuth2LoginSuccessHandler)
                        .failureHandler(oAuth2LoginFailHandler)
                        .userInfoEndpoint((userInfoEndpoint) ->
                                userInfoEndpoint
                                        .userService(customOAuth2UserService)
                        )
                )
                .exceptionHandling(exceptionHandle->{
                    exceptionHandle.accessDeniedHandler(new CustomAccessDeniedHandler())
                            .authenticationEntryPoint(new CustomAuthenticationEntryPoint());
                })

                .addFilterBefore(new JwtFilter(jwtService), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}