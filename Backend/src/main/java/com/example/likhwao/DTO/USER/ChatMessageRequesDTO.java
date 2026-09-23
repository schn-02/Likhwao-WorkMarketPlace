package com.example.likhwao.DTO.USER;


public class ChatMessageRequesDTO {

    private Long orderId;
    private String receiverFirebaseUid;
    private String message;
    private String clientMessageId;
    private String role;
    private String chatTo;


    


    


    public ChatMessageRequesDTO() {
    }

    public String getClientMessageId() {
        return clientMessageId;
    }

    public void setClientMessageId(String clientMessageId) {
        this.clientMessageId = clientMessageId;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public String getReceiverFirebaseUid() {
        return receiverFirebaseUid;
    }

    public void setReceiverFirebaseUid(String receiverFirebaseUid) {
        this.receiverFirebaseUid = receiverFirebaseUid;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getChatTo() {
        return chatTo;
    }

    public void setChatTo(String chatTo) {
        this.chatTo = chatTo;
    }
}