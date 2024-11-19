package com.spaceme.planet.domain;

import com.spaceme.galaxy.domain.GalaxyTheme;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Entity
@Getter
@Setter
public class PlanetTheme {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "planet_theme_id")
    private Long planetThemeId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "galaxy_theme_id")
    private GalaxyTheme galaxyTheme;


    private String theme;

}
