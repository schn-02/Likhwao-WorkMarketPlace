package com.example.likhwao.DTO.USER;


public class ChatMessageResponse {

    private boolean success;
    private String message;

    public ChatMessageResponse() {
    }

    public ChatMessageResponse(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public static ChatMessageResponse success(String message) {
        return new ChatMessageResponse(true, message);
    }

    public static ChatMessageResponse failed(String message) {
        return new ChatMessageResponse(false, message);
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }
}