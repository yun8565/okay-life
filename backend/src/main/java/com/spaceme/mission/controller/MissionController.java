package com.spaceme.mission.controller;

import com.spaceme.mission.dto.request.MissionCreateRequest;
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
}
