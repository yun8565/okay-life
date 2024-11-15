package com.spaceme.Galaxy.Domain;

import com.spaceme.Planet.Domain.PlanetTheme;
import jakarta.persistence.*;

import java.util.List;

@Entity
public class GalaxyTheme {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "galaxy_theme_id")
    private Long galaxyThemeId;

    private String theme;

    @OneToMany(mappedBy = "galaxyType")
    private List<Galaxy> galaxies;

    @OneToMany(mappedBy = "galaxyType")
    private List<PlanetTheme> planetThemes;
}
