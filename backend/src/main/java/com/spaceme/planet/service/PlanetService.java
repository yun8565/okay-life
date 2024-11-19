package com.spaceme.planet.service;

import com.spaceme.galaxy.domain.Galaxy;
import com.spaceme.galaxy.repository.GalaxyRepository;
import com.spaceme.planet.domain.Planet;
import com.spaceme.planet.domain.PlanetTheme;
import com.spaceme.planet.dto.PlanetRequestDTO;
import com.spaceme.planet.dto.PlanetResponseDTO;
import com.spaceme.planet.repository.PlanetRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PlanetService {

    private final PlanetRepository planetRepository;

    public PlanetService(PlanetRepository planetRepository) {
        this.planetRepository = planetRepository;
    }

    // 행성 전체 조회
    public List<PlanetResponseDTO> getAllPlanets(Long galaxyId) {
        return planetRepository.findByGalaxy_GalaxyId(galaxyId).stream()
                .map(this::convertToResponseDTO)
                .collect(Collectors.toList());
    }

    // 행성 수정
    public PlanetResponseDTO updatePlanet(Long planetId, PlanetRequestDTO planetRequestDTO) {
        Planet planet = planetRepository.findById(planetId)
                .orElseThrow(() -> new RuntimeException("Planet not found"));
        planet.setTitle(planetRequestDTO.title());
        planet.setAchieved(planetRequestDTO.achieved());
        Planet updatedPlanet = planetRepository.save(planet);
        return convertToResponseDTO(updatedPlanet);
    }

    // 행성 삭제
    public void deletePlanet(Long planetId) {
        planetRepository.deleteById(planetId);
    }

    // Entity -> ResponseDTO 변환
    private PlanetResponseDTO convertToResponseDTO(Planet planet) {
        return new PlanetResponseDTO(
                planet.getPlanetId(),
                planet.getTitle(),
                planet.getAchieved(),
                planet.getGalaxy().getGalaxyId(),
                planet.getPlanetTheme().getPlanetThemeId()
        );
    }
}
