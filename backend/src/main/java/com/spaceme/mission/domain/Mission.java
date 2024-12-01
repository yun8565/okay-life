package com.spaceme.mission.domain;

import com.spaceme.common.domain.Status;
import com.spaceme.planet.domain.Planet;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

import static com.spaceme.common.domain.Status.*;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class Mission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String content;

    @Column(nullable = false)
    private LocalDate date;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private Status status = SOON;

    @Column(nullable = false)
    private Long createdBy;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    private Planet planet;

    public void updateContent(String content) {
        this.content = content;
    }

    public void updateStatus(Status status) {
        this.status = status;
    }
}
