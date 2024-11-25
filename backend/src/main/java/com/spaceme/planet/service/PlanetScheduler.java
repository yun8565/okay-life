package com.spaceme.planet.service;

import com.spaceme.common.exception.NotFoundException;
import com.spaceme.mission.domain.Mission;
import com.spaceme.mission.repository.MissionRepository;
import com.spaceme.planet.repository.PlanetRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

import static com.spaceme.common.Status.*;

@Service
@RequiredArgsConstructor(access = AccessLevel.PROTECTED)
@Transactional
public class PlanetScheduler {

    private final PlanetRepository planetRepository;
    private final MissionRepository missionRepository;

    @Scheduled(cron = "0 0 0 * * ?")
    public void checkPlanetStatusDaily() {
        LocalDate today = LocalDate.now();

        planetRepository.findByStatus(SOON).forEach(planet -> {
            Mission firstMission = missionRepository.findFirstByPlanetId(planet.getId())
                    .orElseThrow(() -> new NotFoundException("미션을 찾을 수 없습니다."));

            if(firstMission.getDate().equals(today))
                planet.updateStatus(ON_PROGRESS);
        });
    }

    @Scheduled(cron = "0 0 0 * * ?")
    public void checkPlanetAcquirable() {
        planetRepository.findByStatus(ON_PROGRESS).forEach(planet -> {
            LocalDate lastDate = missionRepository.findLastByPlanetId(planet.getId())
                    .orElseThrow(() -> new NotFoundException("미션을 찾을 수 없습니다."))
                    .getDate();

            if(missionRepository.findAllByDate(lastDate).stream()
                    .allMatch(mission -> mission.getStatus().isPast())) {
                planet.updateStatus(ACQUIRABLE);
            }
        });
    }
}
