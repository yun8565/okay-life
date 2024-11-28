package com.spaceme.user.repository;

import com.spaceme.common.AlienConcept;
import com.spaceme.user.domain.NotificationPreference;
import com.spaceme.user.domain.UserPreference;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserPreferenceRepository extends JpaRepository<UserPreference, Long> {
    boolean existsByAlienConceptAndNotificationPreference(AlienConcept concept, NotificationPreference preference);
}
