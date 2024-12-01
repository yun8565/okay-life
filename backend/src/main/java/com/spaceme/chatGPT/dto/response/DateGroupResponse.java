package com.spaceme.chatGPT.dto.response;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.spaceme.common.exception.InternalServerException;

import java.util.List;

public record DateGroupResponse(
        List<ChatGPTDatesResponse> dateGroup
) {
    public String toJsonString() {
        ObjectMapper objectMapper = new ObjectMapper();

        dateGroup().removeIf(group -> group.dates().isEmpty());

        try {
            return objectMapper.writeValueAsString(dateGroup());
        } catch (JsonProcessingException e) {
            throw new InternalServerException("JSON 변환 과정에서 오류가 발생했습니다.");
        }
    }
}
