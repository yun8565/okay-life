package com.spaceme.Planet.Domain;


import com.spaceme.DailyMission.Domain.DailyMission;
import com.spaceme.Galaxy.Domain.Galaxy;
import jakarta.persistence.*;

import java.util.List;

@Entity
public class Planet {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "planet_id")
    private Long planetId;

    @ManyToOne
    @JoinColumn(name = "galaxy_id", nullable = false)
    private Galaxy galaxyId;

    @ManyToOne
    @JoinColumn(name = "planet_theme_id")
    private PlanetTheme planetThemeId;

    private String title;
    private Boolean achieved;

    @OneToMany(mappedBy = "planet")
    private List<DailyMission> dailyMissions;
}
