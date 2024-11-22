package com.spaceme.galaxy.service;

import com.spaceme.chatGPT.dto.request.PlanRequest;
import com.spaceme.chatGPT.dto.response.PlanResponse;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.galaxy.domain.Galaxy;
import com.spaceme.galaxy.dto.response.GalaxyResponse;
import com.spaceme.galaxy.repository.GalaxyRepository;
import com.spaceme.mission.domain.Mission;
import com.spaceme.mission.repository.MissionRepository;
import com.spaceme.planet.domain.Planet;
import com.spaceme.planet.repository.PlanetRepository;
import com.spaceme.planet.service.PlanetService;
import com.spaceme.user.domain.User;
import com.spaceme.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class GalaxyService {

    private final GalaxyRepository galaxyRepository;
    private final UserRepository userRepository;
    private final PlanetService planetService;
    private final MissionRepository missionRepository;
    private final PlanetRepository planetRepository;

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

        Galaxy galaxy = Galaxy.builder()
                .title(planRequest.title())
                // TODO .galaxyTheme() 확률 적용해서 테마 생성
                .user(user)
                .startDate(planRequest.startDate())
                .endDate(planRequest.endDate())
                .build();

        planResponse.planets().forEach(planet -> {
            Planet newPlanet = planetRepository.save(
                    Planet.builder()
                            .galaxy(galaxy)
                            // TODO: planetTheme
                            .title(planet.title())
                            .build()
            );

            planet.missions().forEach(mission ->
                    missionRepository.save(
                            Mission.builder()
                                    .planet(newPlanet)
                                    .date(mission.date())
                                    .content(mission.content())
                                    .build()
                    )
            );
        });

        return galaxyRepository.save(galaxy).getId();
    }
}