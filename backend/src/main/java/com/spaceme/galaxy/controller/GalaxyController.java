package com.spaceme.galaxy.controller;

import com.spaceme.auth.domain.Auth;
import com.spaceme.galaxy.dto.request.GalaxyRequest;
import com.spaceme.galaxy.dto.response.GalaxyResponse;
import com.spaceme.galaxy.service.GalaxyService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/galaxies")
public class GalaxyController {

    private final GalaxyService galaxyService;

    @GetMapping
    public ResponseEntity<List<GalaxyResponse>> findGalaxies(@Auth Long userId) {
        return ResponseEntity.ok(galaxyService.findGalaxies(userId));
    }

    @PostMapping
    public ResponseEntity<Void> createGalaxy(
            @RequestBody GalaxyRequest request,
            @Auth Long userId
    ) {
        galaxyService.saveGalaxy(userId, request);
        return ResponseEntity.noContent().build();
    }
}
