package com.spaceme.chatGPT.dto.request;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.spaceme.common.exception.InternalServerException;

import java.util.List;

public record PlanRequest(
        String title,
        String startDate,
        String endDate,
        int step,
        List<String> days,
        List<AnswerRequest> answers
) {
    public String daysToJsonString() {
        ObjectMapper mapper = new ObjectMapper();

        try {
            return mapper.writeValueAsString(days());
        } catch (JsonProcessingException e) {
            throw new InternalServerException("JSON 변환 과정에서 오류가 발생했습니다.");
        }
    }
}