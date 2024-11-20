package com.spaceme.chatGPT.service;

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
}