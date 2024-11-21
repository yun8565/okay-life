package com.spaceme.galaxy.service;

import com.spaceme.chatGPT.service.ChatGPTService;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.galaxy.domain.Galaxy;
import com.spaceme.galaxy.dto.request.GalaxyModifyRequest;
import com.spaceme.galaxy.dto.request.GalaxyRequest;
import com.spaceme.galaxy.dto.response.GalaxyResponse;
import com.spaceme.galaxy.repository.GalaxyRepository;
import com.spaceme.planet.repository.PlanetRepository;
import com.spaceme.planet.service.PlanetService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class GalaxyService {

    private final GalaxyRepository galaxyRepository;
    private final PlanetRepository planetRepository;
    private final PlanetService planetService;
    private final ChatGPTService chatGPTService;

    @Transactional(readOnly = true)
    public List<GalaxyResponse> findGalaxies() {
        return galaxyRepository.findAllByUserId(1L).stream() //TODO: 인증 기능 추가 시 사용자ID로 변경
            .map(galaxy -> GalaxyResponse.of(
                    galaxy,
                    planetService.findAllByGalaxyId(galaxy.getId())
            ))
            .toList();
    }

    public List<String> createQuestion(String goal){

        List<String> questions = chatGPTService.generateQuestions(goal);

        return questions;
    }

    public void saveGalaxy(GalaxyRequest request) {
        //TODO: 인증 기능 추가 시 사용자ID도 받아오기
        // User user = userRepository.findById()

        Galaxy galaxy = Galaxy.builder()
                .title(request.title())
                // TODO .galaxyTheme() 확률 적용해서 테마 생성
                // TODO .user(user)
                .startDate(request.startDate())
                .endDate(request.endDate())
                .build();

        galaxyRepository.save(galaxy);
    }

    public void modifyGalaxy(Long galaxyId, GalaxyModifyRequest request) {
        Galaxy galaxy = galaxyRepository.findById(galaxyId)
                .orElseThrow(() -> new NotFoundException("행성을 찾을 수 없습니다."));

        galaxy.updateTitle(request.title());
    }

    public void deleteGalaxy(Long galaxyId) {
        galaxyRepository.deleteById(galaxyId);
    }
}
