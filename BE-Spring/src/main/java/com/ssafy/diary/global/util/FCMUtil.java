package com.ssafy.diary.global.util;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.ssafy.diary.domain.notification.dto.FCMNotificationMessageRequestDto;

public class FCMUtil {
    public static void sendMessage(Message message) throws FirebaseMessagingException {
        String registrationToken;

// Send a message to the device corresponding to the provided
// registration token.
        String response = FirebaseMessaging.getInstance().send(message);
// Response is a message ID string.
        System.out.println("Successfully sent message: " + response);
    }
}
