package com.spaceme.chatGPT.dto.response;

import java.util.List;

public record DateGroupResponse(
        List<ChatGPTDatesResponse> dateGroup
) {
}
