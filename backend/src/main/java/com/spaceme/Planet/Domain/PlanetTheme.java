package com.spaceme.Planet.Domain;

import com.spaceme.Galaxy.Domain.GalaxyTheme;
import jakarta.persistence.*;

import java.util.List;

@Entity
public class PlanetTheme {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "planet_theme_id")
    private Long planetThemeId;

    @ManyToOne
    @JoinColumn(name = "galaxy_theme_id")
    private GalaxyTheme galaxyThemeId;

    private String theme;

    @OneToMany(mappedBy = "planetType")
    private List<Planet> planets;
}
