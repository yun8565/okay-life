package com.spaceme.chatGPT.dto.response;

import java.time.LocalDate;

public record ChatGPTMissionResponse(
        String content,
        LocalDate date
) {
}
