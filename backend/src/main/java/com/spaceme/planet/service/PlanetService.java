package com.spaceme.planet.service;

import com.spaceme.common.exception.NotFoundException;
import com.spaceme.mission.service.MissionService;
import com.spaceme.planet.domain.Planet;
import com.spaceme.planet.dto.request.PlanetModifyRequest;
import com.spaceme.planet.dto.response.PlanetResponse;
import com.spaceme.planet.repository.PlanetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PlanetService {

    private final PlanetRepository planetRepository;
    private final MissionService missionService;

    public List<PlanetResponse> findAllByGalaxyId(Long galaxyId) {
        return planetRepository.findByGalaxyId(galaxyId).stream()
            .map(planet -> PlanetResponse.of(
                    planet,
                    missionService.findAllMissionByPlanetId(planet.getId())
            ))
            .toList();
    }

    public void updatePlanet(Long userId, Long planetId, PlanetModifyRequest request) {
        Planet planet = planetRepository.findById(planetId)
                .orElseThrow(() -> new NotFoundException("행성을 찾을 수 없습니다."));

        planet.updateTitle(request.title());
    }
}
