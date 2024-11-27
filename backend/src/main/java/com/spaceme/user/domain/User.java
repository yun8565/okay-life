package com.spaceme.user.domain;

import com.spaceme.auth.domain.ProviderType;
import com.spaceme.common.AlienConcept;
import jakarta.persistence.*;
import lombok.*;

import static com.spaceme.common.AlienConcept.DEFAULT;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String nickname;

    private String deviceToken;

    @Setter
    private String spaceGoal;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private AlienConcept alienConcept = DEFAULT;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProviderType authType;

    public void updateDeviceToken(String deviceToken) {
        this.deviceToken = deviceToken;
    }

    public void updateAlienConcept(AlienConcept alienConcept) {
        this.alienConcept = alienConcept;
    }
}
