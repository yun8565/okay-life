package com.spaceme.chatGPT.dto.response;

import java.time.LocalDate;
import java.util.List;

public record ChatGPTDatesResponse(
        String title,
        List<DatesResponse> dates
) {
}
