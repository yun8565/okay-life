package com.spaceme.planet.domain;

import com.spaceme.collection.domain.PlanetTheme;
import com.spaceme.galaxy.domain.Galaxy;
import com.spaceme.common.Status;
import jakarta.persistence.*;
import lombok.*;

import static com.spaceme.common.Status.SOON;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class Planet {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "galaxy_id", nullable = false)
    private Galaxy galaxy;

    @ManyToOne(optional = false)
    @JoinColumn(name = "planet_theme_id")
    private PlanetTheme planetTheme;

    @Column(nullable = false)
    private String title;

    @Builder.Default
    private Status status = SOON;

    @Column(nullable = false)
    private Long createdBy;

    public void updateStatus(Status status) {
        this.status = status;
    }

    public void updateTitle(String title) {
        this.title = title;
    }

    public void updatePlanetTheme(PlanetTheme planetTheme) {
        this.planetTheme = planetTheme;
    }
}
