package com.spaceme.planet.repository;

import com.spaceme.planet.domain.Planet;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface PlanetRepository extends CrudRepository<Planet, Long> {
    List<Planet> findByGalaxy_GalaxyId(Long galaxyId);
}
