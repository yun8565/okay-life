package com.spaceme.chatGPT.service;

import com.spaceme.chatGPT.dto.request.GoalRequest;
import com.spaceme.chatGPT.dto.request.PlanRequest;
import com.spaceme.chatGPT.dto.response.PlanResponse;
import com.spaceme.chatGPT.dto.response.ThreeResponse;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.galaxy.service.GalaxyService;
import com.spaceme.user.domain.User;
import com.spaceme.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Service
public class ChatGPTService {
    private final WebClient webClient;
    private final UserRepository userRepository;
    private final GalaxyService galaxyService;



    public ThreeResponse generateRoadMap(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자를 찾을 수 없습니다."));

        String prompt = user.getSpaceGoal() + "을 위한 로드맵을 3단계로 제시해줘.\n" +
                "형식에 대한 예시는 아래와 같아.\n" +
                "외고 진학\n" +
                "영어영문과 입학\n" +
                "학원 강사 취업 "+
                "Json 형식으로 three라는 key에 value로 단계별 내용만 넣어줘. 내용을 최대 30자로 해줘.";

        return webClient.post()
                .uri("/chat/completions")
                .bodyValue(Map.of(
                        "model", "gpt-4o-mini",
                        "messages", List.of(Map.of(
                                "role", "user",
                                "content", prompt
                        )),
                        "max_tokens", 1000
                ))
                .retrieve()
                .bodyToMono(ThreeResponse.class)
                .block();
    }

    public ThreeResponse generateQuestions(Long userId, GoalRequest goalRequest) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자를 찾을 수 없습니다."));

        String prompt = goalRequest.goal() + "(이)라는 목표 달성을 위해 질문자의 배경에 대해 알고 싶은 3개의 질문을 생성해줘.\n " +
                "하나의 질문은 무조건 질문자가 목표 달성을 위해 1주에 얼마나 자주 시간을 할애할 수 있는지. json 형식으로 key는 three, value는 질문 내용만";

        return webClient.post()
                .uri("/chat/completions")
                .bodyValue(Map.of(
                        "model", "gpt-4o-mini",
                        "messages", List.of(Map.of(
                                "role", "user",
                                "content", prompt
                        )),
                        "max_tokens", 1000
                ))
                .retrieve()
                .bodyToMono(ThreeResponse.class)
                .block();
    }

    @Transactional
    public Long generatePlan(Long userId, PlanRequest planRequest) {
        String combinedInput = "목표는 " + planRequest.title() + "이야 \n 아래 질의응답을 참고해서 계획을 짜줘 "
                + planRequest.answers().stream()
                .map(answer -> answer.question() + ": " + answer.answer());




         PlanResponse planResponse = webClient.post()
                .uri("/chat/completions")
                .bodyValue(Map.of(
                        "model", "gpt-4o-mini",
                        "messages", List.of(
                                Map.of("role", "system", "content", "너는 사용자의 목표와 질문에 대한 답변에 맞게 계획을 짜주는 전문가야."),
                                Map.of("role", "user", "content", combinedInput)
                        ),
                        "max_tokens", 1500
                ))
                .retrieve()
                .bodyToMono(PlanResponse.class)
                .block();

        return galaxyService.saveGalaxy(userId, planResponse, planRequest);
    }
}