package com.spaceme.DailyMission.Domain;

import com.spaceme.Mission.Domain.Mission;
import com.spaceme.Planet.Domain.Planet;
import jakarta.persistence.*;

import java.util.Date;
import java.util.List;

public class DailyMission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "daily_mission_id")
    private Long dailyMissionId;

    @ManyToOne
    @JoinColumn(name = "planet_id", nullable = false)
    private Planet planet_id;

    private String content;
    private Date date;

    @OneToMany(mappedBy = "dailyMission")
    private List<Mission> missions;
}
