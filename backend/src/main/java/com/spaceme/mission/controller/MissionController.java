package com.spaceme.mission.controller;

import com.spaceme.mission.dto.request.MissionCreateRequest;
import com.spaceme.mission.dto.request.MissionModifyRequest;
import com.spaceme.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/missions")
public class MissionController {

    private final MissionService missionService;

    @PostMapping
    public ResponseEntity<Void> createMission(@RequestBody MissionCreateRequest request) {
        missionService.saveMission(request);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{missionId}")
    public ResponseEntity<Void> modifyMission(
            @PathVariable Long missionId,
            @RequestBody MissionModifyRequest request
    ) {
        missionService.modifyMission(missionId, request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{missionId}")
    public ResponseEntity<Void> deleteMission(@PathVariable Long missionId) {
        missionService.deleteMission(missionId);
        return ResponseEntity.noContent().build();
    }
}
