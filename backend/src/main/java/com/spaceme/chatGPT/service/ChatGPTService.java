package com.spaceme.chatGPT.service;

import com.spaceme.chatGPT.dto.request.GoalRequest;
import com.spaceme.chatGPT.dto.request.PlanRequest;
import com.spaceme.chatGPT.dto.response.ChatGPTResponse;
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
                .bodyToMono(ChatGPTResponse.class)
                .block()
                .toResponse(ThreeResponse.class);
    }

    public ThreeResponse generateQuestions(Long userId, GoalRequest goalRequest) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자를 찾을 수 없습니다."));

        String prompt = goalRequest.goal() + "(이)라는 목표를 달성하기 위한 세부 목표를 세우는데 참고할 정보가 필요해. 질문자에게 맞는 세부 목표를 세울 때, 참고할 수 있는 정보를 얻기 위한 3개의 질문을 생성해줘.\n " +
                " json 형식으로 key는 three, value는 질문 내용만";

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
                .bodyToMono(ChatGPTResponse.class)
                .block()
                .toResponse(ThreeResponse.class);
    }

    @Transactional
    public Long generateDays(Long userId, PlanRequest planRequest) {
        String combinedInput = "p1."+ planRequest.startDate() + "~"+ planRequest.endDate() +"중" + planRequest.days()+ "에 해당하는 일자만 남겨\n" +
                "p2. 남은 일자들을 "+ planRequest.step() +"개의 그룹으로 나눠. 이때 각 그룹별로 포함되어있는 일자 개수가 동일해야해. 등분되지 않는 날짜는 버림처리해줘.\n" +
                "p3.  json 형태로 반환해. 형태는 다음과 같아.\n" +
                "{\n" +
                "\"title\" : group,\n" +
                "\"dates\" : [{\"date\" : \"날짜\"}]\n" +
                "}\n" +
                "json 값만 반환해줘."
                ;


        PlanResponse planResponse = webClient.post()
                .uri("/chat/completions")
                .bodyValue(Map.of(
                        "model", "gpt-4o-mini",
                        "messages", List.of(
                                Map.of("role", "system", "content", "너는 목표를 달성하고 싶은 사용자를 위해 단계별 세부 목표와 계획을 수립해주는 전문가야.\n" +
                                        "사용자의 input을 고려해서 단계별 세부 목표와 계획을 수립해줘.\n"),
                                Map.of("role", "user", "content", combinedInput)
                        ),
                        "max_tokens", 1500
                ))
                .retrieve()
                .bodyToMono(ChatGPTResponse.class)
                .block()
                .toResponse(PlanResponse.class);

        return galaxyService.saveGalaxy(userId, planResponse, planRequest);
    }



    @Transactional
    public Long generatePlan(Long userId, PlanRequest planRequest) {
        String combinedInput =  "input은 다음과 같아.\n" +
                "1. 목표(String) :"+ planRequest.title() +
                "\n 2. 질의응답 (질문(String) : 답변 (String))"
                + planRequest.answers().stream()
                .map(answer -> answer.question() + ": " + answer.answer())+
                "\n" +
                "너가 해야할 일은 다음과 같아.\n" +
                "let’s think step by step."+
                "1. 사용자의 목표를 달성하는데 필요한 세부 목표를 총" + planRequest.step() +
                "개의 단계로 나눠서 세워. 넌 사용자를 고려한 세부 목표 수립 전문가니까 사용자의 목표와 질의응답을 잘 고려해서 세부 목표를 만들어줄 수 있어.\n" +
                "2. 각 세부 목표를 이루기 위한 " + planRequest.days() +
                "개의 계획을 생성해줘. 넌 사용자를 고려한 계획 수립 전문가니까 세부 목표와 질의응답 내용을 잘 고려해서 계획을 만들어줄 수 있어. 각 계획을 하루 단위로 실천해야한다는 점을 고려해서 현실적인 계획을 수립해줘. 문장을 명사로 종결해줘.\n" +
                "3. 세부 목표와 계획을 json 형태로 반환해. 형태는 다음과 같아.\n" +
                "{\"planets\" : [\n" +
                "\"title\" : 세부 목표,\n" +
                "\"missions\" : [{\"content\" : \"계획\"}]\n" +
                "]}\n" +
                "json 값만 반환해줘.";


         PlanResponse planResponse = webClient.post()
                 .uri("/chat/completions")
                 .bodyValue(Map.of(
                        "model", "gpt-4o-mini",
                        "messages", List.of(
                                Map.of("role", "system", "content", "너는 목표를 달성하고 싶은 사용자를 위해 단계별 세부 목표와 계획을 수립해주는 전문가야.\n" +
                                        "사용자의 input을 고려해서 단계별 세부 목표와 계획을 수립해줘.\n"),
                                Map.of("role", "user", "content", combinedInput)
                        ),
                        "max_tokens", 1500
                 ))
                 .retrieve()
                 .bodyToMono(ChatGPTResponse.class)
                 .block()
                 .toResponse(PlanResponse.class);

        return galaxyService.saveGalaxy(userId, planResponse, planRequest);
    }
}