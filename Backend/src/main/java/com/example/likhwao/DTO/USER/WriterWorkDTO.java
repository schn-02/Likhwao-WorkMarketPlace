package com.example.likhwao.DTO.USER;

import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class WriterWorkDTO {
    
     private Long UserOrderId;

   

      //file info
        private String fileName;
        private String userFileName;

       private String fileUrl;
       private String userFileUrl;


    private Long fileSize;
    private Integer filePageCount;

        private Long userFileSize;
    private Integer userFilePageCount;

    // Order details
    private String typeOfWork;
   
    private String writerSuggestionText;
    private String userSuggestionText;

    
    private String selectedDeadLineUrgency;
    private LocalDate selectedDate;


     //Address
    private String  deliveryAddress;
    private Double latitude;
    private Double longitude;

   //Amount
    private int orderPageCountAmount;
    private int urgencyAmount;
    private int  totalOrderAmount;


 


     private String orderStatus;
    private Long writerId; 
    private String cancellationReason;


private LocalDateTime orderCreatedAt;
private LocalDateTime orderCompletedAt;

private Date orderCompletedAt_Review;


private String writerAssignmentStatus ;


    private Long userId;


private String writerFirebaseUid;

  private String selectedInkColor;
    private String selectedNotebook;

  

    private Integer deliveryChargesAmount;
    private Integer platformFeeAmount;
    private Integer noteBookChargesAmount;


    //Payment
    private String razorpayOrderId;
private String paymentId;
private String paymentStatus;

private String paymentMethod;   // UPI / CARD
private String paymentBank; 

//Refund
private String refundStatus;   // UPI / CARD
private String refundId;   

private Long writerWorkId;



public Long getUserFileSize() {
    return userFileSize;
}


public void setUserFileSize(Long userFileSize) {
    this.userFileSize = userFileSize;
}


public Integer getUserFilePageCount() {
    return userFilePageCount;
}


public void setUserFilePageCount(Integer userFilePageCount) {
    this.userFilePageCount = userFilePageCount;
}


public String getUserSuggestionText() {
    return userSuggestionText;
}


public void setUserSuggestionText(String userSuggestionText) {
    this.userSuggestionText = userSuggestionText;
}


public Integer getDeliveryChargesAmount() {
    return deliveryChargesAmount;
}


public void setDeliveryChargesAmount(Integer deliveryChargesAmount) {
    this.deliveryChargesAmount = deliveryChargesAmount;
}


public Integer getPlatformFeeAmount() {
    return platformFeeAmount;
}


public void setPlatformFeeAmount(Integer platformFeeAmount) {
    this.platformFeeAmount = platformFeeAmount;
}


public Integer getNoteBookChargesAmount() {
    return noteBookChargesAmount;
}


public void setNoteBookChargesAmount(Integer noteBookChargesAmount) {
    this.noteBookChargesAmount = noteBookChargesAmount;
}


public String getRazorpayOrderId() {
    return razorpayOrderId;
}


public void setRazorpayOrderId(String razorpayOrderId) {
    this.razorpayOrderId = razorpayOrderId;
}


public String getPaymentId() {
    return paymentId;
}


public void setPaymentId(String paymentId) {
    this.paymentId = paymentId;
}


public String getPaymentStatus() {
    return paymentStatus;
}


public void setPaymentStatus(String paymentStatus) {
    this.paymentStatus = paymentStatus;
}


public String getPaymentMethod() {
    return paymentMethod;
}


public void setPaymentMethod(String paymentMethod) {
    this.paymentMethod = paymentMethod;
}


public String getPaymentBank() {
    return paymentBank;
}


public void setPaymentBank(String paymentBank) {
    this.paymentBank = paymentBank;
}


public String getRefundStatus() {
    return refundStatus;
}


public void setRefundStatus(String refundStatus) {
    this.refundStatus = refundStatus;
}


public String getRefundId() {
    return refundId;
}


public void setRefundId(String refundId) {
    this.refundId = refundId;
}


public String getSelectedInkColor() {
        return selectedInkColor;
    }


    public void setSelectedInkColor(String selectedInkColor) {
        this.selectedInkColor = selectedInkColor;
    }


    public String getSelectedNotebook() {
        return selectedNotebook;
    }


    public void setSelectedNotebook(String selectedNotebook) {
        this.selectedNotebook = selectedNotebook;
    }


public Long getUserOrderid() {
    return UserOrderId;
}


public void setUserOrderid(Long userOrderid) {
    UserOrderId = userOrderid;
}


public String getFileName() {
    return fileName;
}


public void setFileName(String fileName) {
    this.fileName = fileName;
}


public String getFileUrl() {
    return fileUrl;
}


public void setFileUrl(String fileUrl) {
    this.fileUrl = fileUrl;
}


public Long getFileSize() {
    return fileSize;
}


public void setFileSize(Long fileSize) {
    this.fileSize = fileSize;
}


public Integer getFilePageCount() {
    return filePageCount;
}


public void setFilePageCount(Integer filePageCount) {
    this.filePageCount = filePageCount;
}


public String getTypeOfWork() {
    return typeOfWork;
}


public void setTypeOfWork(String typeOfWork) {
    this.typeOfWork = typeOfWork;
}


public String getWriterSuggestionText() {
    return writerSuggestionText;
}


public void setWriterSuggestionText(String writerSuggestionText) {
    this.writerSuggestionText = writerSuggestionText;
}


public String getSelectedDeadLineUrgency() {
    return selectedDeadLineUrgency;
}


public void setSelectedDeadLineUrgency(String selectedDeadLineUrgency) {
    this.selectedDeadLineUrgency = selectedDeadLineUrgency;
}


public LocalDate getSelectedDate() {
    return selectedDate;
}


public void setSelectedDate(LocalDate selectedDate) {
    this.selectedDate = selectedDate;
}


public String getDeliveryAddress() {
    return deliveryAddress;
}


public void setDeliveryAddress(String deliveryAddress) {
    this.deliveryAddress = deliveryAddress;
}


public Double getLatitude() {
    return latitude;
}


public void setLatitude(Double latitude) {
    this.latitude = latitude;
}


public Double getLongitude() {
    return longitude;
}


public void setLongitude(Double longitude) {
    this.longitude = longitude;
}


public int getOrderPageCountAmount() {
    return orderPageCountAmount;
}


public void setOrderPageCountAmount(int orderPageCountAmount) {
    this.orderPageCountAmount = orderPageCountAmount;
}


public int getUrgencyAmount() {
    return urgencyAmount;
}


public void setUrgencyAmount(int urgencyAmount) {
    this.urgencyAmount = urgencyAmount;
}


public int getTotalOrderAmount() {
    return totalOrderAmount;
}


public void setTotalOrderAmount(int totalOrderAmount) {
    this.totalOrderAmount = totalOrderAmount;
}


public String getOrderStatus() {
    return orderStatus;
}


public void setOrderStatus(String orderStatus) {
    this.orderStatus = orderStatus;
}


public Long getWriterId() {
    return writerId;
}


public void setWriterId(Long writerId) {
    this.writerId = writerId;
}


public String getCancellationReason() {
    return cancellationReason;
}


public void setCancellationReason(String cancellationReason) {
    this.cancellationReason = cancellationReason;
}


public LocalDateTime getOrderCreatedAt() {
    return orderCreatedAt;
}


public void setOrderCreatedAt(LocalDateTime orderCreatedAt) {
    this.orderCreatedAt = orderCreatedAt;
}


public LocalDateTime getOrderCompletedAt() {
    return orderCompletedAt;
}


public void setOrderCompletedAt(LocalDateTime orderCompletedAt) {
    this.orderCompletedAt = orderCompletedAt;
}


public Date getOrderCompletedAt_Review() {
    return orderCompletedAt_Review;
}


public void setOrderCompletedAt_Review(Date orderCompletedAt_Review) {
    this.orderCompletedAt_Review = orderCompletedAt_Review;
}


public String getWriterAssignmentStatus() {
    return writerAssignmentStatus;
}


public void setWriterAssignmentStatus(String writerAssignmentStatus) {
    this.writerAssignmentStatus = writerAssignmentStatus;
}


public Long getUserId() {
    return userId;
}


public void setUserId(Long userId) {
    this.userId = userId;
}


public String getWriterFirebaseUid() {
    return writerFirebaseUid;
}


public void setWriterFirebaseUid(String writerFirebaseUid) {
    this.writerFirebaseUid = writerFirebaseUid;
}


public String getUserFileUrl() {
    return userFileUrl;
}


public void setUserFileUrl(String userFileUrl) {
    this.userFileUrl = userFileUrl;
}


public String getUserFileName() {
    return userFileName;
}


public void setUserFileName(String userFileName) {
    this.userFileName = userFileName;
}


public Long getWriterWorkId() {
    return writerWorkId;
}


public void setWriterWorkId(Long writerWorkId) {
    this.writerWorkId = writerWorkId;
}



}
