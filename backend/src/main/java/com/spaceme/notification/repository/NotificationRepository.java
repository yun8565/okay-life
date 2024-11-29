package com.spaceme.notification.repository;

import com.spaceme.common.domain.AlienConcept;
import com.spaceme.notification.domain.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findAllByAlienConcept(AlienConcept concept);
}
