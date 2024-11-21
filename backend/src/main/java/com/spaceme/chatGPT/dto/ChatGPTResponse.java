package com.spaceme.chatGPT.dto;

import lombok.Data;

import java.util.List;

@Data
public class ChatGPTResponse {

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
}
