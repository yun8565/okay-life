package com.spaceme.user.domain;

import com.spaceme.common.AlienConcept;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class UserPreference {
    @Id
    private Long id;

    @MapsId
    @OneToOne(targetEntity = User.class, fetch = FetchType.LAZY, optional = false)
    private User user;

    private String spaceGoal;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private AlienConcept alienConcept = AlienConcept.DEFAULT;

    public void updateSpaceGoal(String spaceGoal) {
        this.spaceGoal = spaceGoal;
    }

    public void updateAlienConcept(AlienConcept alienConcept) {
        this.alienConcept = alienConcept;
    }
}
