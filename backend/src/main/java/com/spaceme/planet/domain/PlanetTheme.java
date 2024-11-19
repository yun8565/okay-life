package com.spaceme.planet.domain;

import com.spaceme.galaxy.domain.GalaxyTheme;
import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Getter
public class PlanetTheme {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    private GalaxyTheme galaxyTheme;

    @Column(nullable = false)
    private String theme;
}
