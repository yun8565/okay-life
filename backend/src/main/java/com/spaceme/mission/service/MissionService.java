package com.spaceme.mission.service;

import com.spaceme.common.exception.ForbiddenException;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.mission.domain.Mission;
import com.spaceme.mission.dto.request.MissionCreateRequest;
import com.spaceme.mission.dto.request.MissionModifyRequest;
import com.spaceme.mission.dto.response.MissionResponse;
import com.spaceme.mission.repository.MissionRepository;
import com.spaceme.planet.domain.Planet;
import com.spaceme.planet.repository.PlanetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

import static com.spaceme.common.domain.Status.CLEAR;

@Service
@RequiredArgsConstructor
@Transactional
public class MissionService {

    private final MissionRepository missionRepository;
    private final PlanetRepository planetRepository;

    public List<MissionResponse> findAllMissionByPlanetId(Long planetId) {
        return missionRepository.findAllByPlanetId(planetId).stream()
                .map(MissionResponse::from)
                .toList();
    }

    public void saveMission(Long userId, MissionCreateRequest request) {
        Planet planet = planetRepository.findById(request.planetId())
                .orElseThrow(() -> new NotFoundException("행성을 찾을 수 없습니다."));

        Mission mission = Mission.builder()
                .content(request.content())
                .date(request.date())
                .planet(planet)
                .createdBy(userId)
                .build();

        missionRepository.save(mission);
    }

    public void modifyMission(Long userId, Long missionId, MissionModifyRequest request) {
        validateMission(userId, missionId);
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(() -> new NotFoundException("미션을 찾을 수 없습니다."));

        mission.updateContent(request.content());
    }

    public void deleteMission(Long userId, Long missionId) {
        validateMission(userId, missionId);
        missionRepository.deleteById(missionId);
    }

    public void setMissionStatusAsClear(Long userId, Long missionId) {
        validateMission(userId, missionId);
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(() -> new NotFoundException("미션을 찾을 수 없습니다."));

        mission.updateStatus(CLEAR);
    }

    public void validateMission(Long userId, Long missionId) {
        Optional.of(missionRepository.existsByIdAndCreatedBy(missionId, userId))
                .filter(Boolean::booleanValue)
                .orElseThrow(() -> new ForbiddenException("접근 권한이 없습니다."));
    }
}