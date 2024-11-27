package com.spaceme.notification.repository;

import com.spaceme.common.AlienConcept;
import com.spaceme.notification.domain.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    @Query(value = "select * from notification n where n.alien_concept = :alienConcept " +
            "order by n.sent, rand() limit 1", nativeQuery = true)
    Optional<Notification> findRandomMessageByConcept(AlienConcept alienConcept);
}
