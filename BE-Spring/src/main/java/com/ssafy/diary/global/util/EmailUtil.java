package com.ssafy.diary.global.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.mail.*;
import javax.mail.internet.*;
import java.security.SecureRandom;
import java.util.Properties;

@Component
@Slf4j
public class EmailUtil {
    private String type = "text/html; charset=utf-8";

    @Value("${email.address}")
    private String emailAddress;


    @Value("${email.password}")
    private String password;

    public void sendMail(String email, String title, String content) {
        Properties properties = new Properties();
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", 587);
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.setProperty("mail.smtp.ssl.protocols", "TLSv1.2");
        Authenticator auth = new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(emailAddress, password);
            }
        };
        Session session = Session.getInstance(properties, auth);
        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(emailAddress, "emo_diary"));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(email));
            message.setSubject(title);
            message.setContent(content, type);
            Transport.send(message);
        } catch (Exception e) {
            e.printStackTrace();
        }
        for (int i = 0; i < 10; i++) {
        log.debug("테스트{}: {}",i,generateCode().toString());

        }
    }

    public static String generateCode() {
        String charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        int stringLength = 8;
        StringBuilder sb = new StringBuilder();
        SecureRandom random = new SecureRandom();
        for (int i = 0; i < stringLength; i++) {
            int randomIndex = random.nextInt(charSet.length());
            sb.append( charSet.charAt(randomIndex));
        }
        return sb.toString();
    }
}