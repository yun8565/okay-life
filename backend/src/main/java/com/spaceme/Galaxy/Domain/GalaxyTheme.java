package com.spaceme.Galaxy.Domain;

import com.spaceme.Planet.Domain.PlanetTheme;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Entity
@Getter
@Setter
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
