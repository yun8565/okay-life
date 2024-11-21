package com.spaceme.chatGPT.controller;

import com.spaceme.chatGPT.service.ChatGPTService;
import com.spaceme.galaxy.service.GalaxyService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chat")
public class ChatGPTController {


    private final ChatGPTService chatGPTService;
    private final GalaxyService galaxyService;

    public ChatGPTController(ChatGPTService chatGPTService, GalaxyService galaxyService) {
        this.chatGPTService = chatGPTService;
        this.galaxyService = galaxyService;
    }

    @PostMapping("/ask")
    public Mono<String> askChatGPT(@RequestBody Map<String, String> request) {
        String prompt = request.get("prompt");
        return chatGPTService.getChatGPTResponse(prompt);
    }

    @PostMapping("/question")
    public List<String> questionChatGPT(@RequestBody Map<String, String> request) {
        String prompt = request.get("prompt");
        return galaxyService.createQuestion(prompt);
    }


}
