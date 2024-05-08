package com.ssafy.diary.global.util;

import com.google.firebase.messaging.*;
import lombok.extern.slf4j.Slf4j;
import org.joda.time.LocalDateTime;
import org.springframework.lang.Nullable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
@Slf4j
public class FCMUtil {
    public static void sendAllNotificationMessage(String title, String message, @Nullable Map<String,String> data, String topic) throws FirebaseMessagingException {
       Message requestMessage=Message.builder()
                        .setNotification(Notification.builder()
                                .setBody(message)
                                .setTitle(title)
                                .build())
                        .putAllData(data)
                        .setAndroidConfig(AndroidConfig.builder()
                                .setTtl(new LocalDateTime().plusDays(7).getMillisOfSecond())
                                .build())
                        .setWebpushConfig(WebpushConfig.builder()
                                .setNotification(WebpushNotification.builder()
                                        .setDirection(WebpushNotification.Direction.AUTO)
                                        .setRenotify(true)
                                        .setLanguage("ko-KR")
                                        .build())
                                .build())
                        .setTopic(topic)
                        .build();

        String response = FirebaseMessaging.getInstance()
                .send(requestMessage);
        log.debug("Successfully sent notification message : {}",response);
    }
    public static void sendAllNotificationMessage(String title, String message, List<String> registrationToken) throws FirebaseMessagingException {
        List<Message> requestMessage=new ArrayList<>();
        registrationToken.forEach(token->
                requestMessage.add(Message.builder()
                        .setNotification(Notification.builder()
                                .setBody(message)
                                .setTitle(title)
                                .build())
                        .setAndroidConfig(AndroidConfig.builder()
                                .setTtl(new LocalDateTime().plusDays(7).getMillisOfSecond())
                                .build())
                        .setWebpushConfig(WebpushConfig.builder()
                                .setNotification(WebpushNotification.builder()
                                        .setDirection(WebpushNotification.Direction.AUTO)
                                        .setRenotify(true)
                                        .setLanguage("ko-KR")
                                        .build())
                                .build())
                        .setToken(token)
                        .build()
                ));

        BatchResponse response = FirebaseMessaging.getInstance()
                .sendEach(requestMessage);
        log.debug("Successfully sent notification message list : {}",response.getResponses());
        log.debug("Failed sent notification message count : {}",response.getFailureCount());
        log.debug("Successful sent notification message count : {}",response.getSuccessCount());
    }
    public static void sendAllNotificationMessage(String title, String message, String imageUrl, List<String> registrationToken) throws FirebaseMessagingException {
        List<Message> requestMessage=new ArrayList<>();
        registrationToken.forEach(token->
                requestMessage.add(Message.builder()
                        .setNotification(Notification.builder()
                                .setBody(message)
                                .setTitle(title)
                                .setImage(imageUrl)
                                .build())
                        .setAndroidConfig(AndroidConfig.builder()
                                .setTtl(new LocalDateTime().plusDays(7).getMillisOfSecond())
                                .build())
                        .setWebpushConfig(WebpushConfig.builder()
                                .setNotification(WebpushNotification.builder()
                                        .setDirection(WebpushNotification.Direction.AUTO)
                                        .setRenotify(true)
                                        .setLanguage("ko-KR")
                                        .build())
                                .build())
                        .setToken(token)
                        .build()
                ));

        BatchResponse response = FirebaseMessaging.getInstance()
                .sendEach(requestMessage);
        log.debug("Successfully sent notification message list : {}",response.getResponses());
        log.debug("Failed sent notification message count : {}",response.getFailureCount());
        log.debug("Successful sent notification message count : {}",response.getSuccessCount());
    }
    public static void sendAllNotificationMessage(String title, String message, @Nullable Map<String,String> data, List<String> registrationToken) throws FirebaseMessagingException {
        List<Message> requestMessage=new ArrayList<>();
                registrationToken.forEach(token->
                                requestMessage.add(Message.builder()
                                .setNotification(Notification.builder()
                                        .setBody(message)
                                        .setTitle(title)
                                        .build())
                                .putAllData(data)
                                .setAndroidConfig(AndroidConfig.builder()
                                        .setTtl(new LocalDateTime().plusDays(7).getMillisOfSecond())
                                        .build())
                                .setWebpushConfig(WebpushConfig.builder()
                                        .setNotification(WebpushNotification.builder()
                                                .setDirection(WebpushNotification.Direction.AUTO)
                                                .setRenotify(true)
                                                .setLanguage("ko-KR")
                                                .build())
                                        .build())
                                .setToken(token)
                                .build()
                        ));

        BatchResponse response = FirebaseMessaging.getInstance()
                .sendEach(requestMessage);
        log.debug("Successfully sent notification message list : {}",response.getResponses());
        log.debug("Failed sent notification message count : {}",response.getFailureCount());
        log.debug("Successful sent notification message count : {}",response.getSuccessCount());
    }
    public static void sendNotificationMessage(String title, String message, @Nullable Map<String,String> data, String registrationToken) throws FirebaseMessagingException {
        Message requestMessage=Message.builder()
                        .setNotification(Notification.builder()
                                .setBody(message)
                                .setTitle(title)
                                .build())
                        .putAllData(data)
                        .setAndroidConfig(AndroidConfig.builder()
                                .setTtl(new LocalDateTime().plusDays(7).getMillisOfSecond())
                                .build())
                        .setWebpushConfig(WebpushConfig.builder()
                                .setNotification(WebpushNotification.builder()
                                        .setDirection(WebpushNotification.Direction.AUTO)
                                        .setRenotify(true)
                                        .setLanguage("ko-KR")
                                        .build())
                                .build())
                        .setToken(registrationToken)
                        .build();

        String response = FirebaseMessaging.getInstance()
                .send(requestMessage);
        log.debug("Successfully sent notification message : {}",response);

    }
    public static void sendNotificationMessage(String title, String message, String registrationToken) throws FirebaseMessagingException {
        Message requestMessage=Message.builder()
                .setNotification(Notification.builder()
                        .setBody(message)
                        .setTitle(title)
                        .build())
                .setAndroidConfig(AndroidConfig.builder()
                        .setTtl(new LocalDateTime().plusDays(7).getMillisOfSecond())
                        .build())
                .setWebpushConfig(WebpushConfig.builder()
                        .setNotification(WebpushNotification.builder()
                                .setDirection(WebpushNotification.Direction.AUTO)
                                .setRenotify(true)
                                .setLanguage("ko-KR")
                                .build())
                        .build())
                .setToken(registrationToken)
                .build();

        String response = FirebaseMessaging.getInstance()
                .send(requestMessage);
        log.debug("Successfully sent notification message : {}",response);

    }
}
