package com.example.likhwao.DTO.USER;


public class WriterFeedbackResponse {

    private boolean success;
    private String message;

    public WriterFeedbackResponse() {
    }

    public WriterFeedbackResponse(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public static WriterFeedbackResponse success(String message) {
        return new WriterFeedbackResponse(true, message);
    }

    public static WriterFeedbackResponse failed(String message) {
        return new WriterFeedbackResponse(false, message);
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }


    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}