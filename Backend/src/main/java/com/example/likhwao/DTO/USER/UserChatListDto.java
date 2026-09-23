package com.example.likhwao.DTO.USER;

import java.time.LocalDateTime;

public class UserChatListDto {

    private Long userId;
    private Long writerId;
    private Long orderId;
    
    private String writerName;
    private String writerLastMessage;
   
    private String writerNumber;
    private String countryCode;
    private String countryName;

    private LocalDateTime createdAt; 


    private Integer totalOrders;

    private String writerFirebaseUid;

    private String orderStatus;





    public Long getUserId() {
        return userId;
    }

    


    public void setUserId(Long userId) {
        this.userId = userId;
    }


    public Long getOrderId() {
        return orderId;
    }


    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }


    public String getWriterName() {
        return writerName;
    }


    public void setWriterName(String writerName) {
        this.writerName = writerName;
    }


    public String getWriterLastMessage() {
        return writerLastMessage;
    }


    public void setWriterLastMessage(String writerLastMessage) {
        this.writerLastMessage = writerLastMessage;
    }


    public String getWriterNumber() {
        return writerNumber;
    }


    public void setWriterNumber(String writerNumber) {
        this.writerNumber = writerNumber;
    }


    public String getCountryCode() {
        return countryCode;
    }


    public void setCountryCode(String countryCode) {
        this.countryCode = countryCode;
    }


    public String getCountryName() {
        return countryName;
    }


    public void setCountryName(String countryName) {
        this.countryName = countryName;
    }


    public LocalDateTime getCreatedAt() {
        return createdAt;
    }


    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }


    public Integer getTotalOrders() {
        return totalOrders;
    }


    public void setTotalOrders(Integer totalOrders) {
        this.totalOrders = totalOrders;
    }


    public Long getWriterId() {
        return writerId;
    }


    public void setWriterId(Long writerId) {
        this.writerId = writerId;
    }




    public String getWriterFirebaseUid() {
        return writerFirebaseUid;
    }




    public void setWriterFirebaseUid(String writerFirebaseUid) {
        this.writerFirebaseUid = writerFirebaseUid;
    }




    public String getOrderStatus() {
        return orderStatus;
    }




    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }  

    

}
