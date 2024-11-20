package com.spaceme.galaxy.service;

import com.spaceme.common.exception.NotFoundException;
import com.spaceme.galaxy.domain.Galaxy;
import com.spaceme.galaxy.dto.request.GalaxyRequest;
import com.spaceme.galaxy.dto.response.GalaxyResponse;
import com.spaceme.galaxy.repository.GalaxyRepository;
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

    @Transactional(readOnly = true)
    public List<GalaxyResponse> findGalaxies(Long userId) {
        return galaxyRepository.findAllByUserId(userId).stream()
            .map(galaxy -> GalaxyResponse.of(
                    galaxy,
                    planetService.findAllByGalaxyId(galaxy.getId())
            ))
            .toList();
    }

    public void saveGalaxy(Long userId, GalaxyRequest request) {
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
    }
}
