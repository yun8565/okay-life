package com.spaceme.notification.domain;

import com.spaceme.common.domain.AlienConcept;
import jakarta.persistence.*;
import lombok.Getter;

import static com.spaceme.common.domain.AlienConcept.DEFAULT;

@Entity
@Getter
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(nullable = false)
    private String message;

    @Enumerated(EnumType.STRING)
    private AlienConcept alienConcept = DEFAULT;
}
