package com.spaceme.mission.domain;

import com.spaceme.planet.domain.Planet;
import jakarta.persistence.*;
import lombok.*;

import static com.spaceme.mission.domain.Status.*;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class Mission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long missionId;

    @Column(nullable = false)
    private String content;

    @Column(nullable = false)
    private LocalDate date;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private Status missionStatus = SOON;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    private Planet planet;

    public void updateContent(String content) {
        this.content = content;
    }

    public void setStatus(Status status) {
        this.missionStatus = status;
    }
}
