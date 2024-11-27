package com.spaceme.notification.domain;

import com.spaceme.common.AlienConcept;
import jakarta.persistence.*;
import lombok.Getter;

import static com.spaceme.common.AlienConcept.DEFAULT;

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

    private int sent;

    public void addSentCount() {
        sent += 1;
    }
}
