package com.spaceme.collection.service;

import com.spaceme.collection.domain.ThemeStatus;
import com.spaceme.collection.dto.GalaxyThemeResponse;
import com.spaceme.collection.dto.PlanetThemeResponse;
import com.spaceme.collection.repository.GalaxyThemeRepository;
import com.spaceme.collection.repository.PlanetThemeRepository;
import com.spaceme.common.Status;
import com.spaceme.planet.repository.PlanetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static com.spaceme.collection.domain.ThemeStatus.*;
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CollectionService {

    private final GalaxyThemeRepository galaxyThemeRepository;
    private final PlanetThemeRepository planetThemeRepository;
    private final PlanetRepository planetRepository;

    public List<GalaxyThemeResponse> getThemeCollection(Long userId) {
        LinkedHashMap<Long, ThemeStatus> planetMap = planetRepository.findAllByUserId(userId).stream()
                .collect(Collectors.toMap(planet -> planet.getPlanetTheme().getId(),
                        planet -> determineStatus(planet.getStatus()),
                        (existing, replacement) -> existing,
                        LinkedHashMap::new
                ));

        return galaxyThemeRepository.findAll(Sort.by("id")).stream()
                .map(galaxyTheme -> {
                    List<PlanetThemeResponse> planetThemeResponses = getPlanetThemeResponses(galaxyTheme.getId(), planetMap);
                    return GalaxyThemeResponse.of(galaxyTheme, planetThemeResponses);
                })
                .toList();
    }

    private List<PlanetThemeResponse> getPlanetThemeResponses(Long galaxyThemeId, Map<Long, ThemeStatus> planetMap) {
        return planetThemeRepository.findByGalaxyThemeId(galaxyThemeId).stream()
                .map(planetTheme -> {
                    ThemeStatus status = planetMap.getOrDefault(planetTheme.getId(), HIDDEN);
                    return PlanetThemeResponse.of(planetTheme, status);
                })
                .toList();
    }

    private ThemeStatus determineStatus(Status status) {
        return switch (status) {
            case CLEAR -> ACQUIRED;
            case SOON, FAILED, ACQUIRABLE, ON_PROGRESS -> DISCOVERED;
        };
    }
}
