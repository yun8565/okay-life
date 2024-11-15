package com.spaceme.Mission.Domain;

import com.spaceme.DailyMission.Domain.DailyMission;
import jakarta.persistence.*;

@Entity
public class Mission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "mission_id")
    private Long missionId;

    @ManyToOne
    @JoinColumn(name = "daily_mission_id", nullable = false)
    private DailyMission dailyMissionId;

    private Boolean achieved;
    private String content;
}
