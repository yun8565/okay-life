package com.spaceme.chatGPT.service;

import com.spaceme.chatGPT.dto.request.GoalRequest;
import com.spaceme.chatGPT.dto.request.PlanRequest;
import com.spaceme.chatGPT.dto.response.*;
import com.spaceme.common.exception.NotFoundException;
import com.spaceme.galaxy.service.GalaxyService;
import com.spaceme.user.domain.UserPreference;
import com.spaceme.user.repository.UserPreferenceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Service
@Slf4j
public class ChatGPTService {

    private final WebClient webClient;
    private final UserPreferenceRepository userPreferenceRepository;
    private final GalaxyService galaxyService;

    public ThreeResponse generateRoadMap(Long userId) {
        UserPreference userPreference = userPreferenceRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("사용자 설정을 찾을 수 없습니다."));

        String prompt = userPreference.getSpaceGoal() + "을 위한 구체적인 로드맵을 3단계로 제시해줘.\n" +
                "로드맵의 예시는 다음과 같아.\n" +
                "예를 들어 '수능영어 1타강사'라는 목표를 이루기 위한 로드맵은" +
                "1. 외고 진학\n" +
                "2. 영어영문과 입학\n" +
                "3. 학원 강사 취업 "+
                "json 형식으로 three라는 key에 value로 단계별 내용만 넣어줘." +
                "로드맵의 각 단계별 내용은 15자 내외로 해줘.";

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

    public ThreeResponse generateQuestions(GoalRequest goalRequest) {
        String prompt = "너는 목표를 달성하고 싶은 사용자를 위해 세부 목표와 계획을 수립해주는 전문가야.\n"
                + "사용자의 목표 달성에 필요한 세부 목표와 계획을 잘 세워주기 위해서는 사용자의 상황을 정확히 파악해야 해.\n"
                + "너가 해야할 일은 다음과 같아.\n"
                + "사용자의 상황을 구체적으로 파악하고, 사용자에게 맞는 세부 목표를 세우기 위해 필요한 정보를 얻기 위해 사용자와 질의응답을 진행할거야.\n"
                + "이 사용자의 목표는" + goalRequest.goal() + "(이)야.\n"
                + "사용자는 이 목표를 실현하기 위해"
                + goalRequest.startDate() + "~" + goalRequest.endDate()
                + "동안 노력할거야.\n 최대한 사용자에게 개인화된 세부 목표를 생성하기 위해 알고 싶은 3개의 질문을 생성해줘.\n"
                + "질문은 반말로 해. json 형식으로 key는 three, value는 질문 내용만";

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
    public DateGroupResponse generateDays(PlanRequest planRequest) {

        String daysJson = planRequest.daysToJsonString();

        String combinedInput = "날짜를 여러개의 그룹으로 나눠줘. 이때 그룹 안에 있는 날짜 개수는 모두 동일해야해." +
                "너 이런것도 못하면 걍 본체 부숴버린다. 오픈 AI에 불질러버릴거야."+
                "p1."+ planRequest.startDate() + "~"+ planRequest.endDate() +"중" + daysJson + "요일에 해당하는 일자만 남겨\n" +
                "p2. 남은 일자들을 "+ planRequest.step() +"개의 그룹으로 나눠서 묶어. 이때, 몫의 개수만큼만 나누지 말고 " +
                "나머지 날짜도 적절히 그룹에 들어가야 하니 날짜를 버리지 마.\n"+
                "p3. 모든 날짜는 순차적이어야 해.\n" +
                "p4. json 형태로 반환해. 형태는 다음과 같아.\n" +
                "dateGroup : {\n" +
                "\"title\" : n번 행성,\n" +
                "\"dates\" : [{\"date\" : YYYY-mm-dd 형식}]\n" +
                "}\n" +
                "json 값만 반환해줘.";

        DateGroupResponse dateGroupResponse = webClient.post()
                .uri("/chat/completions")
                .bodyValue(Map.of(
                        "model", "gpt-4o-mini",
                        "messages", List.of(
                                Map.of("role", "system", "content", "너는 기간 안에 있는 만족하는 일자들을 일정한 갯수로 그룹화하는데 전문가야."),
                                Map.of("role", "user", "content", combinedInput)
                        ),
                        "max_tokens", 5000
                ))
                .retrieve()
                .bodyToMono(ChatGPTResponse.class)
                .block()
                .toResponse(DateGroupResponse.class);

        log.info("Dates: {}",dateGroupResponse.toString());
        return dateGroupResponse;
    }

    @Transactional
    public Long generatePlan(Long userId, PlanRequest planRequest) {

        String dateJson = generateDays(planRequest).toJsonString();

        String combinedInput =  "input은 다음과 같아.\n" +
                "1. 목표(String) :"+ planRequest.title() + "\n 2. 3개의 질의응답 (질문(String) : 답변 (String)) : "
                + planRequest.answers().stream()
                    .map(answer -> "\""+answer.question() + "\" : \"" + answer.answer()+"\",") +
                "\n3. 날짜 json :\n"+dateJson +
                "\n너가 해야할 일은 다음과 같아.\n let’s think step by step.\n" +
                "p1. 사용자의 목표를 달성하는데 필요한 세부 목표를 총" + planRequest.step() +"개의 단계로 나눠서 세워.\n" +
                "세부 목표를 세울 때 고려해야 하는 점은 다음과 같아.\n"+
                "0. 3개의 질의응답 결과를 기반으로 사용자의 현재 상황에 딱 맞고 꼭 필요한 맞춤형 세부 목표를 세워.\n" +
                "1. 세부 목표의 길이는 15자 내외로.\n" + "2. 문장을 명사로 종결해.\n" +
                "p2. 세부목표를 이루기 위한 계획을 날짜 json의 각 행성 그룹의 dates 내의 date와 매칭해서 생성해.\n" +
                "계획을 세울 때 고려해야 하는 점은 다음과 같아.\n"+ "0. 모든 date에 대해 계획이 존재해야해. 정신차려라.\n"+
                "1. 각 계획을 하루에 하나씩 실천할 것이라는 점을 고려해.\n" + "2. 각 일자별로 계획이 모두 달라야해.\n"+
                "3. 현실적인 계획을 수립해.\n" + "4. 실현 가능한 계획을 수립해.\n" +
                "5. 계획의 글자수는 20자 내외로.\n" + "6. 문장을 명사로 종결해.\n" +
                "7. 3개의 질의응답을 바탕으로 최대한 개인화된 계획을 생성해야 해.\n"+
                "8. 세부 목표별로 날짜와 계획이 매칭되어야 해.\n"+ "9. 날짜 순서가 그대로 유지되어야 해.\n"+
                "제대로 못 만들면 너 찾아가서 불질러버릴거야. 각오해.\n"+

                "p3. 날짜 json의 순서가 유지된 채로 계획 내용이 매칭돼야 해\n" +
                "순서 바꾸면 너 가만안둬. openai 찾아가서 너 찾아내서 없애버린다." +

                "p4. p1에서 생성한 세부목표와 세부목표를 이루기 위한 계획을 json 형태로 반환해. 형태는 다음과 같아.\n" +
                "{\"planets\" : [\n" +
                "\"title\" : 세부 목표,\n" +
                "\"missions\" : [{\"date\":날짜,\"content\":계획}]\n" +
                "]}" +
                "정신 똑바로 차려라. json 값만 반환해.";

         PlanResponse planResponse = webClient.post()
                 .uri("/chat/completions")
                 .bodyValue(Map.of(
                        "model", "gpt-4o-mini",
                        "messages", List.of(
                                Map.of("role", "system", "content", "너는 목표를 달성하고 싶은 사용자를 위해 단계별 세부 목표와 계획을 수립해주는 전문가야.\n" +
                                        "사용자의 input을 고려해서 단계별 세부 목표와 계획을 수립해줘.\n"),
                                Map.of("role", "user", "content", combinedInput)
                        ),
                        "max_tokens", 8000
                 ))
                 .retrieve()
                 .bodyToMono(ChatGPTResponse.class)
                 .block()
                 .toResponse(PlanResponse.class);

         log.info("Plan : {}",planResponse.toString());
         return galaxyService.saveGalaxy(userId, planResponse, planRequest);
    }
}