package com.spaceme.galaxy.service;

import com.spaceme.chatGPT.service.ChatGPTService;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.galaxy.domain.Galaxy;
import com.spaceme.galaxy.dto.request.GalaxyModifyRequest;
import com.spaceme.galaxy.dto.request.GalaxyRequest;
import com.spaceme.galaxy.dto.response.GalaxyResponse;
import com.spaceme.galaxy.repository.GalaxyRepository;
import com.spaceme.planet.repository.PlanetRepository;
import com.spaceme.planet.service.PlanetService;
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
    private final ChatGPTService chatGPTService;
    private final MissionRepository missionRepository;

    @Transactional(readOnly = true)
    public List<GalaxyResponse> findGalaxies(Long userId) {
        return galaxyRepository.findAllByUserId(userId).stream()
            .map(galaxy -> GalaxyResponse.of(
                    galaxy,
                    planetService.findAllByGalaxyId(galaxy.getId())
            ))
            .toList();
    }

    public void saveGalaxy(Long userId, PlanResponse planResponse, PlanRequest planRequest) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자를 찾을 수 없습니다."));


        Galaxy galaxy = Galaxy.builder()
                .title(request.title())
                // TODO .galaxyTheme() 확률 적용해서 테마 생성
                .user(user)
                .startDate(request.startDate())
                .endDate(request.endDate())
                .build();

        galaxyRepository.save(galaxy);

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

    }


}
