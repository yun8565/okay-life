package com.spaceme.chatGPT.dto.response;

import java.util.List;

public record PlanResponse(
        List<ChatGPTPlanetResponse> planets
) {
}
