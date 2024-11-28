package com.spaceme.planet.service;

import com.spaceme.collection.service.DynamicProbabilityGenerator;
import com.spaceme.common.exception.BadRequestException;
import com.spaceme.common.exception.ForbiddenException;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.mission.repository.MissionRepository;
import com.spaceme.mission.service.MissionService;
import com.spaceme.planet.domain.Planet;
import com.spaceme.planet.dto.request.PlanetModifyRequest;
import com.spaceme.planet.dto.response.PlanetResponse;
import com.spaceme.planet.dto.response.RatioResponse;
import com.spaceme.planet.repository.PlanetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

import static com.spaceme.common.Status.ACQUIRABLE;
import static com.spaceme.common.Status.CLEAR;

@Service
@RequiredArgsConstructor
@Transactional
public class PlanetService {

    private final PlanetRepository planetRepository;
    private final MissionService missionService;
    private final MissionRepository missionRepository;
    private final DynamicProbabilityGenerator probabilityGenerator;

    @Transactional(readOnly = true)
    public List<PlanetResponse> findAllByGalaxyId(Long galaxyId) {
        return planetRepository.findByGalaxyId(galaxyId).stream()
            .map(planet -> PlanetResponse.of(
                    planet,
                    missionService.findAllMissionByPlanetId(planet.getId()),
                    missionRepository.findFirstByPlanetId(planet.getId())
                            .orElseThrow(() -> new NotFoundException("미션을 찾을 수 없습니다."))
                            .getDate(),
                    missionRepository.findLastByPlanetId(planet.getId())
                            .orElseThrow(() -> new NotFoundException("미션을 찾을 수 없습니다."))
                            .getDate()
            ))
            .toList();
    }

    public void updatePlanet(Long userId, Long planetId, PlanetModifyRequest request) {
        validatePlanet(userId, planetId);
        Planet planet = planetRepository.findById(planetId)
                .orElseThrow(() -> new NotFoundException("행성을 찾을 수 없습니다."));

        planet.updateTitle(request.title());
    }

    public RatioResponse acquirePlanet(Long userId, Long planetId) {
        validatePlanet(userId, planetId);
        checkIfAcquirable(planetId);

        double probability = getProbability(planetId);
        boolean hasAcquired = probabilityGenerator.acquirePlanetTheme(probability);

        if(hasAcquired) {
            Planet planet = planetRepository.findById(planetId)
                    .orElseThrow(() -> new NotFoundException("행성을 찾을 수 없습니다."));
            planet.updateStatus(CLEAR);
        }
        return RatioResponse.of(hasAcquired, (int)(probability*100));
    }

    private double getProbability(Long planetId) {
        Long totalCount = missionRepository.countByPlanetId(planetId);

        if(totalCount == 0)
            throw new BadRequestException("행성에 속한 미션을 찾을 수 없습니다.");

        long clearedCount = missionService.findAllMissionByPlanetId(planetId).stream()
                .filter(mission -> mission.status().equals(CLEAR))
                .count();
        return (double) clearedCount / totalCount;
    }

    private void checkIfAcquirable(Long planetId) {
        planetRepository.findById(planetId)
                .filter(planet -> planet.getStatus().equals(ACQUIRABLE))
                .orElseThrow(() -> new BadRequestException("행성을 정복할 수 없는 상태입니다."));
    }

    @Transactional(readOnly = true)
    public void validatePlanet(Long userId, Long planetId) {
        Optional.of(planetRepository.existsByIdAndCreatedBy(planetId, userId))
                .filter(Boolean::booleanValue)
                .orElseThrow(() -> new ForbiddenException("접근 권한이 없습니다."));
    }
}
