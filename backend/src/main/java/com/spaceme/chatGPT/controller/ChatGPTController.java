package com.spaceme.chatGPT.controller;

import com.spaceme.chatGPT.service.ChatGPTService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.util.Map;

@RestController
@RequestMapping("/api/chat")
public class ChatGPTController {


    private final ChatGPTService chatGPTService;

    public ChatGPTController(ChatGPTService chatGPTService) {
        this.chatGPTService = chatGPTService;
    }

    @PostMapping("/ask")
    public Mono<String> askChatGPT(@RequestBody Map<String, String> request) {
        String prompt = request.get("prompt");
        return chatGPTService.getChatGPTResponse(prompt);
    }
}
