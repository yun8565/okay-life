package com.spaceme.planet.domain;


import com.spaceme.galaxy.domain.Galaxy;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;


@Entity
@Getter
@Setter
public class Planet {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "planet_id")
    private Long planetId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "galaxy_id", nullable = false)
    private Galaxy galaxy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "planet_theme_id")
    private PlanetTheme planetTheme;

    @Column(nullable = false)
    private String title;
    private Boolean achieved;

}
