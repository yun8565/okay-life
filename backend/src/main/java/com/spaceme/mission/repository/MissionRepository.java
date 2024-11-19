package com.spaceme.mission.repository;

import com.spaceme.mission.domain.Mission;
import com.spaceme.mission.domain.Status;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface MissionRepository extends JpaRepository<Mission, Long> {
    List<Mission> findAllByDate(LocalDate date);
    List<Mission> findAllByMissionStatusAndDate(Status status, LocalDate date);
}
