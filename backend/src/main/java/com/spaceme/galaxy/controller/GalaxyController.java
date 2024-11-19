package com.spaceme.galaxy.controller;

import com.spaceme.galaxy.dto.request.GalaxyModifyRequest;
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
    public ResponseEntity<List<GalaxyResponse>> findGalaxies() {
        return ResponseEntity.ok(galaxyService.findGalaxies());
    }

    @PostMapping
    public ResponseEntity<Void> createGalaxy(@RequestBody GalaxyRequest request) {
        galaxyService.saveGalaxy(request);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{galaxyId}")
    public ResponseEntity<Void> modifyGalaxy(
            @PathVariable Long galaxyId,
            @RequestBody GalaxyModifyRequest request
    ) {
        galaxyService.modifyGalaxy(galaxyId, request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{galaxyId}")
    public ResponseEntity<Void> deleteGalaxy(@PathVariable Long galaxyId) {
        galaxyService.deleteGalaxy(galaxyId);
        return ResponseEntity.noContent().build();
    }
}
