package com.spaceme.mission.controller;

import com.spaceme.auth.domain.Auth;
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
    public ResponseEntity<Void> createMission(
            @RequestBody MissionCreateRequest request,
            @Auth Long userId
    ) {
        missionService.saveMission(userId, request);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{missionId}")
    public ResponseEntity<Void> modifyMission(
            @PathVariable Long missionId,
            @RequestBody MissionModifyRequest request,
            @Auth Long userId
    ) {
        missionService.modifyMission(userId, missionId, request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{missionId}")
    public ResponseEntity<Void> deleteMission(
            @PathVariable Long missionId,
            @Auth Long userId
    ) {
        missionService.deleteMission(userId, missionId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{missionId}/status")
    public ResponseEntity<Void> setMissionStatus(
            @PathVariable Long missionId,
            @Auth Long userId
    ) {
        missionService.setMissionStatusAsClear(userId, missionId);
        return ResponseEntity.ok().build();
    }
}