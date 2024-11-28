package com.spaceme.mission.service;

import com.spaceme.mission.repository.MissionRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

import static com.spaceme.common.Status.*;

@Service
@RequiredArgsConstructor(access = AccessLevel.PROTECTED)
@Slf4j
@Transactional
public class MissionScheduler {

    private final MissionRepository missionRepository;

    @Scheduled(cron = "0 0 0 * * ?")
    public void checkMissionStatusDaily() {
        LocalDate today = LocalDate.now();

        missionRepository.findAllByDate(today)
                .forEach(mission -> mission.updateStatus(ON_PROGRESS));
        log.info("미션 진행 상황 일괄 업데이트 성공");
    }

    @Scheduled(cron = "0 0 0 * * ?")
    public void checkMissionStatusYesterday() {
        LocalDate yesterday = LocalDate.now().minusDays(1);

        missionRepository.findAllByStatusAndDate(ON_PROGRESS, yesterday)
                .forEach(mission -> mission.updateStatus(FAILED));
        log.info("수행하지 않은 미션 상태 일괄 업데이트 성공");
    }
}
