package com.example.likhwao.DTO.ADMIN;

public class AdminOrderDetailsResponseDto {
    
    public String status;
    public String message;
    
    private Long orderId;

private String writerSubmissionVersion;

private String orderStatus;
private String writerAssignmentStatus;
private String statusLabel;

private String userName;
private String userNumber;
private String userFirebaseUid;

private String writerName;
private String writerFirebaseUid;

private String fileName;
private String userFileUrl;
private String userFilePath;
private int filePageCount;
private Long fileSize;

private String writerSubmissionFileName;
private String writerSubmissionFileUrl;
private String writerSubmissionFilePath;
private String writerSubmissionVideoUrl;
private String writerSubmissionText;
private String writerSubmittedAt;

private String typeOfWork;
private String selectedLanguage;
private String selectedInkColor;
private String selectedNotebook;
private String workToBeDone;
private String writerSuggestionText;

private String deliveryPickupOption;
private String deliveryAddress;

private String urgency;
private String deadline;

private int orderPageCountAmount;
private int urgencyAmount;
private int deliveryChargesAmount;
private int platformFeeAmount;
private int noteBookChargesAmount;
private int totalOrderAmount;

private String paymentStatus;
private String paymentMethod;
private String paymentBank;

private String orderCreatedAt;
private String orderCompletedAt;




public String getOrderCompletedAt() {
    return orderCompletedAt;
}

public void setOrderCompletedAt(String orderCompletedAt) {
    this.orderCompletedAt = orderCompletedAt;
}

public Long getOrderId() {
    return orderId;
}

public void setOrderId(Long orderId) {
    this.orderId = orderId;
}

public String getWriterSubmissionVersion() {
    return writerSubmissionVersion;
}

public void setWriterSubmissionVersion(String writerSubmissionVersion) {
    this.writerSubmissionVersion = writerSubmissionVersion;
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

public String getUserFirebaseUid() {
    return userFirebaseUid;
}

public void setUserFirebaseUid(String userFirebaseUid) {
    this.userFirebaseUid = userFirebaseUid;
}

public String getWriterName() {
    return writerName;
}

public void setWriterName(String writerName) {
    this.writerName = writerName;
}

public String getWriterFirebaseUid() {
    return writerFirebaseUid;
}

public void setWriterFirebaseUid(String writerFirebaseUid) {
    this.writerFirebaseUid = writerFirebaseUid;
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

public int getFilePageCount() {
    return filePageCount;
}

public void setFilePageCount(int filePageCount) {
    this.filePageCount = filePageCount;
}

public Long getFileSize() {
    return fileSize;
}

public void setFileSize(Long fileSize) {
    this.fileSize = fileSize;
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

public String getWorkToBeDone() {
    return workToBeDone;
}

public void setWorkToBeDone(String workToBeDone) {
    this.workToBeDone = workToBeDone;
}

public String getWriterSuggestionText() {
    return writerSuggestionText;
}

public void setWriterSuggestionText(String writerSuggestionText) {
    this.writerSuggestionText = writerSuggestionText;
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

public int getDeliveryChargesAmount() {
    return deliveryChargesAmount;
}

public void setDeliveryChargesAmount(int deliveryChargesAmount) {
    this.deliveryChargesAmount = deliveryChargesAmount;
}

public int getPlatformFeeAmount() {
    return platformFeeAmount;
}

public void setPlatformFeeAmount(int platformFeeAmount) {
    this.platformFeeAmount = platformFeeAmount;
}

public int getNoteBookChargesAmount() {
    return noteBookChargesAmount;
}

public void setNoteBookChargesAmount(int noteBookChargesAmount) {
    this.noteBookChargesAmount = noteBookChargesAmount;
}

public int getTotalOrderAmount() {
    return totalOrderAmount;
}

public void setTotalOrderAmount(int totalOrderAmount) {
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

  public AdminOrderDetailsResponseDto(String status, String message) {
        this.status = status;
        this.message = message;
    }



}
