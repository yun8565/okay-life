package com.spaceme.galaxy.controller;

import com.spaceme.galaxy.dto.GalaxyDTO;
import com.spaceme.galaxy.service.GalaxyService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/galaxies")
public class GalaxyController {

    private final GalaxyService galaxyService;

    public GalaxyController(GalaxyService galaxyService) {
        this.galaxyService = galaxyService;
    }

    // GET: 전체 은하수 조회
    @GetMapping
    public ResponseEntity<List<GalaxyDTO>> getAllGalaxies() {
        List<GalaxyDTO> galaxies = galaxyService.getAllGalaxies();
        return ResponseEntity.ok(galaxies);
    }

    // GET: 내 은하수 도감 조회
    @GetMapping("/book")
    public ResponseEntity<List<GalaxyDTO>> getUserGalaxies(@RequestParam Long userId) {
        List<GalaxyDTO> userGalaxies = galaxyService.getUserGalaxies(userId);
        return ResponseEntity.ok(userGalaxies);
    }

    // POST: 은하수 생성
    @PostMapping
    public ResponseEntity<GalaxyDTO> createGalaxy(@RequestBody GalaxyDTO galaxyDTO) {
        GalaxyDTO createdGalaxy = galaxyService.createGalaxy(galaxyDTO);
        return ResponseEntity.status(201).body(createdGalaxy);
    }

    // PUT: 은하수 수정
    @PutMapping("/{galaxyId}")
    public ResponseEntity<GalaxyDTO> updateGalaxy(@PathVariable Long galaxyId, @RequestBody GalaxyDTO galaxyDTO) {
        GalaxyDTO updatedGalaxy = galaxyService.updateGalaxy(galaxyId, galaxyDTO);
        return ResponseEntity.ok(updatedGalaxy);
    }

    // DELETE: 은하수 삭제
    @DeleteMapping("/{galaxyId}")
    public ResponseEntity<Void> deleteGalaxy(@PathVariable Long galaxyId) {
        galaxyService.deleteGalaxy(galaxyId);
        return ResponseEntity.noContent().build();
    }
}
