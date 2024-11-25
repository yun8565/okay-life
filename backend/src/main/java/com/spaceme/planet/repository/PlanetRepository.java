package com.spaceme.planet.repository;

import com.spaceme.common.Status;
import com.spaceme.planet.domain.Planet;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface PlanetRepository extends CrudRepository<Planet, Long> {
    List<Planet> findByGalaxyId(Long galaxyId);
    List<Planet> findByStatus(Status status);
    @Query("select p FROM Planet p inner join Galaxy g on p.galaxy.id = g.id where g.user.id = :userId")
    List<Planet> findAllByUserId(Long userId);
    boolean existsByIdAndCreatedBy(Long planetId, Long userId);
}
