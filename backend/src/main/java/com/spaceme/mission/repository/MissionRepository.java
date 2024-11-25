package com.spaceme.mission.repository;

import com.spaceme.mission.domain.Mission;
import com.spaceme.common.Status;
import com.spaceme.planet.domain.Planet;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface MissionRepository extends JpaRepository<Mission, Long> {
    List<Mission> findAllByDate(LocalDate date);
    List<Mission> findAllByStatusAndDate(Status status, LocalDate date);
    List<Mission> findAllByPlanetId(Long planetId);
    boolean existsByIdAndCreatedBy(Long id, Long createdBy);
    long countByPlanet(Planet planet);
    long countByPlanetAndStatus(Planet planet, Status status);
}
