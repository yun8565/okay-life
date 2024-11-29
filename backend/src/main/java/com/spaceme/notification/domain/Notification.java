package com.spaceme.notification.domain;

import com.spaceme.common.domain.AlienConcept;
import com.spaceme.common.domain.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;

import java.time.LocalDate;
import java.util.Optional;

import static com.spaceme.common.domain.AlienConcept.DEFAULT;

@Entity
@Getter
public class Notification extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(nullable = false)
    private String message;

    @Enumerated(EnumType.STRING)
    private AlienConcept alienConcept = DEFAULT;

    private int sent;

    public void updateCountIfNewDay(LocalDate today) {
        Optional.ofNullable(getModifiedDate())
                .filter(lastModified -> !lastModified.toLocalDate().equals(today))
                .ifPresentOrElse(
                        lastModified -> sent++,
                        () -> sent++
                );
    }
}
