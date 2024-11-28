package com.spaceme.user.dto.request;

import com.spaceme.common.AlienConcept;
import com.spaceme.user.domain.NotificationPreference;

import java.util.Optional;

public record PreferenceRequest(
        Optional<String> spaceGoal,
        Optional<AlienConcept> alienConcept,
        Optional<NotificationPreference> notificationPreference
) {
}
