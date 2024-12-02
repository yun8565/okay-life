package com.spaceme.planet.controller;

import com.spaceme.auth.domain.Auth;
import com.spaceme.planet.dto.request.PlanetModifyRequest;
import com.spaceme.planet.dto.response.PlanetResponse;
import com.spaceme.planet.dto.response.RatioResponse;
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
            @RequestBody PlanetModifyRequest request,
            @Auth Long userId
    ) {
        planetService.updatePlanet(userId, planetId, request);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{planetId}")
    public ResponseEntity<RatioResponse> acquirePlanet(
            @PathVariable Long planetId,
            @Auth Long userId
    ) {
        return ResponseEntity.ok(planetService.acquirePlanet(userId, planetId));
    }

    @PutMapping("/test/{planetId}")
    public void updatePlanetAndMissions(@PathVariable Long planetId) {
        planetService.updatePlanetAndMissions(planetId);
    }
}