package com.spaceme.galaxy.domain;

import com.spaceme.planet.domain.PlanetTheme;
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

}
