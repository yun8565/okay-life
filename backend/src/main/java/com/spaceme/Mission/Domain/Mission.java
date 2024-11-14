package com.spaceme.Mission.Domain;

import com.spaceme.DailyMission.Domain.DailyMission;
import jakarta.persistence.*;

public class Mission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "mission_id")
    private Long mission_id;

    @ManyToOne
    @JoinColumn(name = "daily_mission_id", nullable = false)
    private DailyMission daily_mission_id;

    private Boolean achieved;
    private String content;
}
