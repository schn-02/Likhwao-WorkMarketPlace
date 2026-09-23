package com.example.likhwao.DTO.ADMIN;

public class AdminDisputeOrderDetailsResponseDto {

    public String status;
    public String message;

    public Long disputeId;
    public Long orderId;

    public String disputeStatus;
    public String disputeReason;
    public String disputeMessage;
    public String orderStatusAtDispute;
    public String writerSubmissionVersion;
    public String disputeCreatedAt;
    public String disputeUpdatedAt;

    public String orderStatus;
    public String writerAssignmentStatus;
    public String statusLabel;

    public String userFirebaseUid;
    public String userName;
    public String userNumber;

    public String writerFirebaseUid;
    public String writerName;

    public String fileName;
    public String userFileUrl;
    public String userFilePath;
    public Long fileSize;
    public Integer filePageCount;

    public String writerSubmissionFileName;
    public String writerSubmissionFileUrl;
    public String writerSubmissionFilePath;
    public String writerSubmissionVideoUrl;
    public String writerSubmissionText;
    public String writerSubmittedAt;

    public String typeOfWork;
    public String selectedLanguage;
    public String selectedInkColor;
    public String selectedNotebook;
    public String writerSuggestionText;
    public String workToBeDone;

    public String deliveryPickupOption;
    public String deliveryAddress;
    public Double latitude;
    public Double longitude;

    public String urgency;
    public String deadline;

    public Integer orderPageCountAmount;
    public Integer urgencyAmount;
    public Integer deliveryChargesAmount;
    public Integer platformFeeAmount;
    public Integer noteBookChargesAmount;
    public Integer totalOrderAmount;

    public String paymentStatus;
    public String paymentMethod;
    public String paymentBank;

    public String orderCreatedAt;
    public String orderCompletedAt;

    public AdminDisputeOrderDetailsResponseDto() {
    }

    public AdminDisputeOrderDetailsResponseDto(String status, String message) {
        this.status = status;
        this.message = message;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Long getDisputeId() {
        return disputeId;
    }

    public void setDisputeId(Long disputeId) {
        this.disputeId = disputeId;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public String getDisputeStatus() {
        return disputeStatus;
    }

    public void setDisputeStatus(String disputeStatus) {
        this.disputeStatus = disputeStatus;
    }

    public String getDisputeReason() {
        return disputeReason;
    }

    public void setDisputeReason(String disputeReason) {
        this.disputeReason = disputeReason;
    }

    public String getDisputeMessage() {
        return disputeMessage;
    }

    public void setDisputeMessage(String disputeMessage) {
        this.disputeMessage = disputeMessage;
    }

    public String getOrderStatusAtDispute() {
        return orderStatusAtDispute;
    }

    public void setOrderStatusAtDispute(String orderStatusAtDispute) {
        this.orderStatusAtDispute = orderStatusAtDispute;
    }

    public String getWriterSubmissionVersion() {
        return writerSubmissionVersion;
    }

    public void setWriterSubmissionVersion(String writerSubmissionVersion) {
        this.writerSubmissionVersion = writerSubmissionVersion;
    }

    public String getDisputeCreatedAt() {
        return disputeCreatedAt;
    }

    public void setDisputeCreatedAt(String disputeCreatedAt) {
        this.disputeCreatedAt = disputeCreatedAt;
    }

    public String getDisputeUpdatedAt() {
        return disputeUpdatedAt;
    }

    public void setDisputeUpdatedAt(String disputeUpdatedAt) {
        this.disputeUpdatedAt = disputeUpdatedAt;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public String getWriterAssignmentStatus() {
        return writerAssignmentStatus;
    }

    public void setWriterAssignmentStatus(String writerAssignmentStatus) {
        this.writerAssignmentStatus = writerAssignmentStatus;
    }

    public String getStatusLabel() {
        return statusLabel;
    }

    public void setStatusLabel(String statusLabel) {
        this.statusLabel = statusLabel;
    }

    public String getUserFirebaseUid() {
        return userFirebaseUid;
    }

    public void setUserFirebaseUid(String userFirebaseUid) {
        this.userFirebaseUid = userFirebaseUid;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserNumber() {
        return userNumber;
    }

    public void setUserNumber(String userNumber) {
        this.userNumber = userNumber;
    }

    public String getWriterFirebaseUid() {
        return writerFirebaseUid;
    }

    public void setWriterFirebaseUid(String writerFirebaseUid) {
        this.writerFirebaseUid = writerFirebaseUid;
    }

    public String getWriterName() {
        return writerName;
    }

    public void setWriterName(String writerName) {
        this.writerName = writerName;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getUserFileUrl() {
        return userFileUrl;
    }

    public void setUserFileUrl(String userFileUrl) {
        this.userFileUrl = userFileUrl;
    }

    public String getUserFilePath() {
        return userFilePath;
    }

    public void setUserFilePath(String userFilePath) {
        this.userFilePath = userFilePath;
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

    public String getWriterSubmissionFileName() {
        return writerSubmissionFileName;
    }

    public void setWriterSubmissionFileName(String writerSubmissionFileName) {
        this.writerSubmissionFileName = writerSubmissionFileName;
    }

    public String getWriterSubmissionFileUrl() {
        return writerSubmissionFileUrl;
    }

    public void setWriterSubmissionFileUrl(String writerSubmissionFileUrl) {
        this.writerSubmissionFileUrl = writerSubmissionFileUrl;
    }

    public String getWriterSubmissionFilePath() {
        return writerSubmissionFilePath;
    }

    public void setWriterSubmissionFilePath(String writerSubmissionFilePath) {
        this.writerSubmissionFilePath = writerSubmissionFilePath;
    }

    public String getWriterSubmissionVideoUrl() {
        return writerSubmissionVideoUrl;
    }

    public void setWriterSubmissionVideoUrl(String writerSubmissionVideoUrl) {
        this.writerSubmissionVideoUrl = writerSubmissionVideoUrl;
    }

    public String getWriterSubmissionText() {
        return writerSubmissionText;
    }

    public void setWriterSubmissionText(String writerSubmissionText) {
        this.writerSubmissionText = writerSubmissionText;
    }

    public String getWriterSubmittedAt() {
        return writerSubmittedAt;
    }

    public void setWriterSubmittedAt(String writerSubmittedAt) {
        this.writerSubmittedAt = writerSubmittedAt;
    }

    public String getTypeOfWork() {
        return typeOfWork;
    }

    public void setTypeOfWork(String typeOfWork) {
        this.typeOfWork = typeOfWork;
    }

    public String getSelectedLanguage() {
        return selectedLanguage;
    }

    public void setSelectedLanguage(String selectedLanguage) {
        this.selectedLanguage = selectedLanguage;
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

    public String getWriterSuggestionText() {
        return writerSuggestionText;
    }

    public void setWriterSuggestionText(String writerSuggestionText) {
        this.writerSuggestionText = writerSuggestionText;
    }

    public String getWorkToBeDone() {
        return workToBeDone;
    }

    public void setWorkToBeDone(String workToBeDone) {
        this.workToBeDone = workToBeDone;
    }

    public String getDeliveryPickupOption() {
        return deliveryPickupOption;
    }

    public void setDeliveryPickupOption(String deliveryPickupOption) {
        this.deliveryPickupOption = deliveryPickupOption;
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

    public String getUrgency() {
        return urgency;
    }

    public void setUrgency(String urgency) {
        this.urgency = urgency;
    }

    public String getDeadline() {
        return deadline;
    }

    public void setDeadline(String deadline) {
        this.deadline = deadline;
    }

    public Integer getOrderPageCountAmount() {
        return orderPageCountAmount;
    }

    public void setOrderPageCountAmount(Integer orderPageCountAmount) {
        this.orderPageCountAmount = orderPageCountAmount;
    }

    public Integer getUrgencyAmount() {
        return urgencyAmount;
    }

    public void setUrgencyAmount(Integer urgencyAmount) {
        this.urgencyAmount = urgencyAmount;
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

    public Integer getTotalOrderAmount() {
        return totalOrderAmount;
    }

    public void setTotalOrderAmount(Integer totalOrderAmount) {
        this.totalOrderAmount = totalOrderAmount;
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

    public String getOrderCreatedAt() {
        return orderCreatedAt;
    }

    public void setOrderCreatedAt(String orderCreatedAt) {
        this.orderCreatedAt = orderCreatedAt;
    }

    public String getOrderCompletedAt() {
        return orderCompletedAt;
    }

    public void setOrderCompletedAt(String orderCompletedAt) {
        this.orderCompletedAt = orderCompletedAt;
    }


    
}