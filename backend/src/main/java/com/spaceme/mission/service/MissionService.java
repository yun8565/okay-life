package com.spaceme.mission.service;

import com.spaceme.mission.domain.Mission;
import com.spaceme.mission.dto.request.MissionCreateRequest;
import com.spaceme.mission.dto.request.MissionModifyRequest;
import com.spaceme.mission.repository.MissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.NoSuchElementException;

import static com.spaceme.mission.domain.Status.CLEAR;

@Service
@RequiredArgsConstructor
@Transactional
public class MissionService {

    private final MissionRepository missionRepository;
    private final PlanetRepository planetRepository;

    public void saveMission(MissionCreateRequest request) {
        Planet planet = planetRepository.findById(request.planetId());
                //TODO: orElseThrow로 예외 처리

        Mission mission = Mission.builder()
                .content(request.content())
                .date(request.date())
                .planet(planet)
                .build();

        missionRepository.save(mission);
    }

    public void modifyMission(Long missionId, MissionModifyRequest request) {
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(NoSuchElementException::new);

        mission.updateContent(request.content());
    }

    public void deleteMission(Long missionId) {
        missionRepository.deleteById(missionId);
    }

    public void setMissionStatusAsClear(Long missionId) {
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(NoSuchElementException::new);

        mission.setStatus(CLEAR);
    }
}