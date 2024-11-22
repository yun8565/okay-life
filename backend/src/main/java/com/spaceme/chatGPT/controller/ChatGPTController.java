package com.spaceme.chatGPT.controller;

import com.spaceme.auth.domain.Auth;
import com.spaceme.chatGPT.dto.request.GoalRequest;
import com.spaceme.chatGPT.dto.request.PlanRequest;
import com.spaceme.chatGPT.dto.response.ThreeResponse;
import com.spaceme.chatGPT.service.ChatGPTService;
import com.spaceme.galaxy.service.GalaxyService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;

@RestController
@RequestMapping("/chat")
public class ChatGPTController {


    private final ChatGPTService chatGPTService;
    private final GalaxyService galaxyService;


    public ChatGPTController(ChatGPTService chatGPTService, GalaxyService galaxyService) {
        this.chatGPTService = chatGPTService;
        this.galaxyService = galaxyService;
    }

    @PostMapping("/goal")
    public ResponseEntity<ThreeResponse> goalChatGPT(@Auth Long userId) {
        return ResponseEntity.ok(chatGPTService.generateRoadMap(userId));
    }

    @PostMapping("/question")
    public ResponseEntity<ThreeResponse> questionChatGPT(@Auth Long userId, @RequestBody GoalRequest goalRequest) {
        return ResponseEntity.ok(chatGPTService.generateQuestions(userId, goalRequest));
    }

    @PostMapping("/final")
    public ResponseEntity<Void> ChatGPT(@Auth Long userId, @RequestBody PlanRequest planRequest) {
        return ResponseEntity.created(URI.create("chat/"+chatGPTService.generatePlan(userId, planRequest))).build();
    }




}
