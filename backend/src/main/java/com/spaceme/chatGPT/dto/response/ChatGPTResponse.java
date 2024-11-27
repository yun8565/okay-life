package com.spaceme.chatGPT.dto.response;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.spaceme.common.exception.InternalServerException;
import lombok.Data;

import java.util.List;

@Data
public class ChatGPTResponse {

    private static final String CODE_FORMAT = "^```json|```$";

    private String id;
    private String object;
    private long created;
    private String model;
    private List<Choice> choices; // 응답 내용
    private Usage usage;          // 토큰 사용량

    @Data
    public static class Choice {
        private int index;
        private Message message;
        private String finish_reason;
    }

    @Data
    public static class Message {
        private String role;      // assistant/user/system
        private String content;   // 응답 내용
    }

    @Data
    public static class Usage {
        private int prompt_tokens;
        private int completion_tokens;
        private int total_tokens;
    }

    public <T> T toResponse(Class<T> clazz) {
        ObjectMapper mapper = new ObjectMapper();

        String content = choices.get(0).message.getContent().replaceAll(CODE_FORMAT,"").trim();

        System.out.println(content);

        try {
            return mapper.readValue(content, clazz);
        } catch (Exception e) {
            throw new InternalServerException("ChatGPT 응답 매핑에 실패했습니다.");
        }


    }
}