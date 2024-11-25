package com.spaceme.mission.repository;

import com.spaceme.mission.domain.Mission;
import com.spaceme.common.Status;
import com.spaceme.planet.domain.Planet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface MissionRepository extends JpaRepository<Mission, Long> {
    List<Mission> findAllByDate(LocalDate date);

    List<Mission> findAllByStatusAndDate(Status status, LocalDate date);

    List<Mission> findAllByPlanetId(Long planetId);

    boolean existsByIdAndCreatedBy(Long id, Long createdBy);

    Long countByPlanetId(Long planetId);

    @Query(value = "select * from mission m where m.planet_id = :planetId" +
            " order by m.date desc limit 1", nativeQuery = true)
    Optional<Mission> findLastByPlanetId(Long planetId);

    @Query(value = "select * from mission m where m.planet_id = :planetId" +
            " order by m.date asc limit 1", nativeQuery = true)
    Optional<Mission> findFirstByPlanetId(Long planetId);
}
