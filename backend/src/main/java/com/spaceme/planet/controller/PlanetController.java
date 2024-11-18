package com.spaceme.planet.controller;

import com.spaceme.planet.dto.PlanetRequestDTO;
import com.spaceme.planet.dto.PlanetResponseDTO;
import com.spaceme.planet.service.PlanetService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/planets")
public class PlanetController {

    private final PlanetService planetService;

    public PlanetController(PlanetService planetService) {
        this.planetService = planetService;
    }

    // 행성 전체 조회
    @GetMapping
    public ResponseEntity<List<PlanetResponseDTO>> getAllPlanets(@RequestParam Long galaxyId) {
        List<PlanetResponseDTO> planets = planetService.getAllPlanets(galaxyId);
        return ResponseEntity.ok(planets);
    }

    // 행성 수정
    @PutMapping("/{planetId}")
    public ResponseEntity<PlanetResponseDTO> updatePlanet(
            @PathVariable Long planetId,
            @RequestBody PlanetRequestDTO planetRequestDTO) {
        PlanetResponseDTO updatedPlanet = planetService.updatePlanet(planetId, planetRequestDTO);
        return ResponseEntity.ok(updatedPlanet);
    }

    // 행성 삭제
    @DeleteMapping("/{planetId}")
    public ResponseEntity<Void> deletePlanet(@PathVariable Long planetId) {
        planetService.deletePlanet(planetId);
        return ResponseEntity.noContent().build();
    }
}