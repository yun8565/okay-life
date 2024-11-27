package com.spaceme.chatGPT.dto.response;


import java.util.List;

public record ChatGPTPlanetResponse(
        List<ChatGPTMissionResponse> missions,
        String title
) {
}
