package com.spaceme.chatGPT.service;

import com.spaceme.chatGPT.dto.ChatGPTResponse;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Map;

@Service
public class ChatGPTService {
    private final WebClient webClient;

    public ChatGPTService(WebClient webClient) {
        this.webClient = webClient;
    }

    public Mono<String> getChatGPTResponse(String prompt) {
        return webClient.post()
                .uri("/chat/completions")
                .bodyValue(Map.of(
                        "model", "gpt-4o-mini",
                        "messages", List.of(Map.of(
                                "role", "user",
                                "content", prompt
                        )),
                        "max_tokens", 1500 // 응답 길이 제한
                ))
                .retrieve()
                .bodyToMono(String.class);
    }

    public List<String> generateQuestions(String goal) {
        return webClient.post()
                .uri("/chat/completions")
                .bodyValue(Map.of(
                        "model", "gpt-4o-mini",
                        "messages", List.of(
                                Map.of("role", "system", "content", "너는 목표 달성 전문가야."),
                                Map.of("role", "user", "content", goal + "이라는 목표를 세웠는데, 목표 달성 계획을 세우는데 필요한 3가지 질문을 생성해서, 다른 말은 하지 말고 Spring에서 List<String>으로 받을 수 있는 형태로 알려줘.")
                        ),
                        "max_tokens", 1000
                ))
                .retrieve()
                .bodyToMono(ChatGPTResponse.class)
                .block()
                .getChoices().stream()
                .map(choice -> choice.getMessage().getContent())
                .toList();
    }
}