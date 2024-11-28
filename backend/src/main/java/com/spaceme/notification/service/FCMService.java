package com.spaceme.notification.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.spaceme.common.AlienConcept;
import com.spaceme.common.exception.InternalServerException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class FCMService {

    private final static String TITLE = "우주정복";

    private final FirebaseMessaging firebaseMessaging;

    @Transactional
    public void sendPushNotification(AlienConcept alienConcept, String notificationMessage) {
        Message message = Message.builder()
                .setNotification(
                        Notification.builder()
                                .setTitle(TITLE)
                                .setBody(notificationMessage)
                                .build()
                )
                .setTopic(alienConcept.name())
                .build();

        try {
            firebaseMessaging.send(message);
            log.info("FCM 메시지 전송 성공 -- TOPIC = {}", alienConcept.name());
        } catch (Exception e) {
            log.error("FCM 메시지 전송 실패 -- TOPIC = {}, ERROR = {}", alienConcept.name(), e.getMessage());
            throw new InternalServerException("FCM 메시지 전송 중 오류가 발생했습니다.");
        }
    }

    public void subscribeTopic(String topic, String deviceToken) {
        try {
            firebaseMessaging.subscribeToTopic(List.of(deviceToken), deviceToken);
            log.info("구독 성공 -- TOKEN = {}, TOPIC = {}", deviceToken, topic);
        } catch (Exception exception) {
            log.error("구독 실패 -- {}", exception.getMessage());
            throw new InternalServerException("FCM 설정 과정에서 오류가 발생했습니다.");
        }
    }

    public void unSubscribeTopic(String topic, String deviceToken) {
        try {
            firebaseMessaging.unsubscribeFromTopic(List.of(deviceToken), topic);
            log.info("구독 취소 성공 -- TOKEN = {}, TOPIC = {}", deviceToken, topic);
        } catch (Exception exception) {
            log.error("구독 취소에 실패 -- {}", exception.getMessage());
            throw new InternalServerException("FCM 설정 과정에서 오류가 발생했습니다.");
        }
    }
}
