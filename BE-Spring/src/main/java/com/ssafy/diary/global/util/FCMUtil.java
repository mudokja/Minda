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
    private static final long DEFAULT_ANDROID_TTL_TIME= 60L *1000*60*24*3;
    public static void sendAllNotificationMessage(String title, String message, @Nullable Map<String,String> data, String topic, @Nullable Long androidTtlSec) throws FirebaseMessagingException {
        Message requestMessage=Message.builder()
                .setNotification(Notification.builder()
                        .setBody(message)
                        .setTitle(title)
                        .build())
                .putAllData(data)
                .setAndroidConfig(AndroidConfig.builder()
                        .setTtl(androidTtlSec==null?DEFAULT_ANDROID_TTL_TIME:androidTtlSec*1000)
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
        showResponseLog(response);
    }
    public static void sendAllNotificationMessage(String title, String message, List<String> registrationToken, @Nullable Long androidTtlSec) throws FirebaseMessagingException {
        List<Message> requestMessage=new ArrayList<>();
        registrationToken.forEach(token->
                requestMessage.add(Message.builder()
                        .setNotification(Notification.builder()
                                .setBody(message)
                                .setTitle(title)
                                .build())
                        .setAndroidConfig(AndroidConfig.builder()
                                .setTtl(androidTtlSec==null?DEFAULT_ANDROID_TTL_TIME:androidTtlSec*1000)
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
        showBatchResponseLog(response);
    }
    public static void sendAllNotificationMessage(String title, String message, String imageUrl, List<String> registrationToken, @Nullable Long androidTtlSec) throws FirebaseMessagingException {
        List<Message> requestMessage=new ArrayList<>();
        registrationToken.forEach(token->
                requestMessage.add(Message.builder()
                        .setNotification(Notification.builder()
                                .setBody(message)
                                .setTitle(title)
                                .setImage(imageUrl)
                                .build())
                        .setAndroidConfig(AndroidConfig.builder()
                                .setTtl(androidTtlSec==null?DEFAULT_ANDROID_TTL_TIME:androidTtlSec*1000)
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
        showBatchResponseLog(response);
    }
    public static void sendAllNotificationMessage(String title, String message, @Nullable Map<String,String> data, List<String> registrationToken, @Nullable Long androidTtlSec) throws FirebaseMessagingException {
        List<Message> requestMessage=new ArrayList<>();
        registrationToken.forEach(token->
                requestMessage.add(Message.builder()
                        .setNotification(Notification.builder()
                                .setBody(message)
                                .setTitle(title)
                                .build())
                        .putAllData(data)
                        .setAndroidConfig(AndroidConfig.builder()
                                .setTtl(androidTtlSec==null?DEFAULT_ANDROID_TTL_TIME:androidTtlSec*1000)
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
        showBatchResponseLog(response);
    }

    private static void showBatchResponseLog(BatchResponse response) {
        log.debug("Successfully sent notification message list : {}", response.getResponses());
        log.debug("Failed sent notification message count : {}", response.getFailureCount());
        log.debug("Successful sent notification message count : {}", response.getSuccessCount());
    }

    public static void sendNotificationMessage(String title, String message, @Nullable Map<String,String> data, String registrationToken, @Nullable Long androidTtlSec) throws FirebaseMessagingException {
        Message requestMessage=Message.builder()
                .setNotification(Notification.builder()
                        .setBody(message)
                        .setTitle(title)
                        .build())
                .putAllData(data)
                .setAndroidConfig(AndroidConfig.builder()
                        .setTtl(androidTtlSec==null?DEFAULT_ANDROID_TTL_TIME:androidTtlSec*1000)
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
        showResponseLog(response);

    }
    public static void sendNotificationMessage(String title, String message, String registrationToken, @Nullable Long androidTtlSec) throws FirebaseMessagingException {
        Message requestMessage=Message.builder()
                .setNotification(Notification.builder()
                        .setBody(message)
                        .setTitle(title)
                        .build())
                .setAndroidConfig(AndroidConfig.builder()
                        .setTtl(androidTtlSec==null ?DEFAULT_ANDROID_TTL_TIME:androidTtlSec*1000)
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
        showResponseLog(response);

    }
    public static void sendAllNotificationMessage(String title, String message, @Nullable Map<String,String> data, String topic) throws FirebaseMessagingException {
       Message requestMessage=Message.builder()
                        .setNotification(Notification.builder()
                                .setBody(message)
                                .setTitle(title)
                                .build())
                        .putAllData(data)
                        .setAndroidConfig(AndroidConfig.builder()
                                .setTtl(DEFAULT_ANDROID_TTL_TIME)
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
        showResponseLog(response);
    }

    private static void showResponseLog(String response) {
        log.debug("Successfully sent notification message : {}", response);
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
                                .setTtl(DEFAULT_ANDROID_TTL_TIME)
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
        showBatchResponseLog(response);
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
                                .setTtl(DEFAULT_ANDROID_TTL_TIME)
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
        showBatchResponseLog(response);
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
                                        .setTtl(DEFAULT_ANDROID_TTL_TIME)
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
        showBatchResponseLog(response);
    }
    public static void sendNotificationMessage(String title, String message, @Nullable Map<String,String> data, String registrationToken) throws FirebaseMessagingException {
        Message requestMessage=Message.builder()
                        .setNotification(Notification.builder()
                                .setBody(message)
                                .setTitle(title)
                                .build())
                        .putAllData(data)
                        .setAndroidConfig(AndroidConfig.builder()
                                .setTtl(DEFAULT_ANDROID_TTL_TIME)
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
        showResponseLog(response);

    }
    public static void sendNotificationMessage(String title, String message, String registrationToken) throws FirebaseMessagingException {
        Message requestMessage=Message.builder()
                .setNotification(Notification.builder()
                        .setBody(message)
                        .setTitle(title)
                        .build())
                .setAndroidConfig(AndroidConfig.builder()
                        .setTtl(DEFAULT_ANDROID_TTL_TIME)
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
        showResponseLog(response);

    }
}
