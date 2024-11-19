package com.spaceme.planet.controller;

import com.spaceme.planet.dto.request.PlanetModifyRequest;
import com.spaceme.planet.dto.response.PlanetResponse;
import com.spaceme.planet.service.PlanetService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/planets")
public class PlanetController {

    private final PlanetService planetService;

    @PutMapping("/{planetId}")
    public ResponseEntity<PlanetResponse> updatePlanet(
            @PathVariable Long planetId,
            @RequestBody PlanetModifyRequest request
    ) {
        planetService.updatePlanet(planetId, request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{planetId}")
    public ResponseEntity<Void> deletePlanet(@PathVariable Long planetId) {
        planetService.deletePlanet(planetId);
        return ResponseEntity.noContent().build();
    }
}