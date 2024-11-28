package com.spaceme.galaxy.service;

import com.spaceme.chatGPT.dto.request.PlanRequest;
import com.spaceme.chatGPT.dto.response.ChatGPTMissionResponse;
import com.spaceme.chatGPT.dto.response.ChatGPTPlanetResponse;
import com.spaceme.chatGPT.dto.response.PlanResponse;
import com.spaceme.collection.service.DynamicProbabilityGenerator;
import com.spaceme.common.exception.ForbiddenException;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.galaxy.domain.Galaxy;
import com.spaceme.galaxy.dto.response.GalaxyResponse;
import com.spaceme.galaxy.repository.GalaxyRepository;
import com.spaceme.mission.domain.Mission;
import com.spaceme.mission.repository.MissionRepository;
import com.spaceme.mission.service.MissionScheduler;
import com.spaceme.planet.domain.Planet;
import com.spaceme.planet.repository.PlanetRepository;
import com.spaceme.planet.service.PlanetScheduler;
import com.spaceme.planet.service.PlanetService;
import com.spaceme.user.domain.User;
import com.spaceme.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class GalaxyService {

    private final GalaxyRepository galaxyRepository;
    private final UserRepository userRepository;
    private final PlanetService planetService;
    private final MissionRepository missionRepository;
    private final PlanetRepository planetRepository;
    private final PlanetScheduler planetScheduler;
    private final MissionScheduler missionScheduler;
    private final DynamicProbabilityGenerator themeGenerator;

    @Transactional(readOnly = true)
    public List<GalaxyResponse> findGalaxies(Long userId) {
        return galaxyRepository.findAllByUserId(userId).stream()
            .map(galaxy -> GalaxyResponse.of(
                    galaxy, planetService.findAllByGalaxyId(galaxy.getId())
            ))
            .toList();
    }

    @Transactional(readOnly = true)
    public GalaxyResponse findGalaxy(Long galaxyId) {
        return galaxyRepository.findById(galaxyId)
                .map(galaxy -> GalaxyResponse.of(
                        galaxy, planetService.findAllByGalaxyId(galaxyId)
                ))
                .orElseThrow(() -> new NotFoundException("존재하지 않는 은하수입니다."));
    }

    public Long saveGalaxy(Long userId, PlanResponse planResponse, PlanRequest planRequest) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자를 찾을 수 없습니다."));

        Galaxy galaxy = createGalaxy(planRequest, user);
        Long galaxyId = galaxyRepository.save(galaxy).getId();

        savePlanetsAndMissions(userId, planResponse, galaxy);

        return galaxyId;
    }

    private void savePlanetsAndMissions(Long userId, PlanResponse planResponse, Galaxy galaxy) {
        planResponse.planets().forEach(planet -> {
            Planet newPlanet = savePlanet(userId, galaxy, planet);
            saveMissions(userId, newPlanet, planet.missions());
        });

        planetScheduler.checkPlanetStatusDaily();
        missionScheduler.checkMissionStatusDaily();
    }

    private Planet savePlanet(Long userId, Galaxy galaxy, ChatGPTPlanetResponse planetResponse) {
        return planetRepository.save(
                Planet.builder()
                        .galaxy(galaxy)
                        .planetTheme(themeGenerator.getRandomPlanetTheme())
                        .createdBy(userId)
                        .title(planetResponse.title())
                        .build()
        );
    }

    private void saveMissions(Long userId, Planet planet, List<ChatGPTMissionResponse> missions) {
        missions.forEach(mission ->
                missionRepository.save(
                        Mission.builder()
                                .planet(planet)
                                .date(LocalDate.parse(mission.date()))
                                .createdBy(userId)
                                .content(mission.content())
                                .build()
                )
        );
    }

    private Galaxy createGalaxy(PlanRequest planRequest, User user) {
        return Galaxy.builder()
                .title(planRequest.title())
                .galaxyTheme(themeGenerator.getRandomGalaxyTheme())
                .user(user)
                .startDate(LocalDate.parse(planRequest.startDate()))
                .endDate(LocalDate.parse(planRequest.endDate()))
                .days(planRequest.days())
                .build();
    }

    public void reroll(Long userId, Long galaxyId) {
        validateGalaxy(userId, galaxyId);
        Galaxy galaxy = galaxyRepository.findById(galaxyId)
                .orElseThrow(() -> new NotFoundException("은하수를 찾을 수 없습니다."));

        galaxy.updateGalaxyTheme(themeGenerator.getRandomGalaxyTheme());
        planetRepository.findByGalaxyId(galaxyId).forEach(planet ->
                planet.updatePlanetTheme(themeGenerator.getRandomPlanetTheme())
        );
    }

    @Transactional(readOnly = true)
    public void validateGalaxy(Long userId, Long galaxyId) {
        Optional.of(galaxyRepository.existsByIdAndUserId(galaxyId, userId))
                .filter(Boolean::booleanValue)
                .orElseThrow(() -> new ForbiddenException("접근 권한이 없습니다."));
    }
}