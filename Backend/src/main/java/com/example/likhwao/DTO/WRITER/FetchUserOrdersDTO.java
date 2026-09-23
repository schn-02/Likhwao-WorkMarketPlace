package com.example.likhwao.DTO.WRITER;

import java.time.LocalDate;
import java.time.LocalDateTime;



public class FetchUserOrdersDTO {

      
      private Long UserOrderid;

   

      //file info
        private String fileName;
       private String userFileUrl;
       private String userFilePath;


    private Long fileSize;
    private Integer userFilePageCount;

    

    // Order details
    private String typeOfWork;
    private String languageSelectedChips;
    private String selectedInkColor;
    private String selectedNotebook;
    private String writerSuggestionText;
    private String deliveryOption;
    private String deliveryPickupOption;
    private String selectedDeadLineUrgency;
    private LocalDate selectedDate;

    private String userFirebaseUid;


    
    //Address
    private String  deliveryAddress;
    private Double latitude;
    private Double longitude;

   //Amount
    private int orderPageCountAmount;
    private int urgencyAmount;
    private int deliveryChargesAmount;
    private int platformFeeAmount;
    private int noteBookChargesAmount;
    private int  totalOrderAmount;


 


private String orderStatus;
private Long writerId; 
private String cancellationReason;


private LocalDateTime orderCreatedAt;
private LocalDateTime orderCompletedAt;

private String writerAssignmentStatus ;

       private Long Addressid;
        private String fullName;
    private String mobileNumber;
    private String pincode;
    private String houseNo;
    private String locality;
    private String city;
    private String state;
    private String saveAs;

    private Long userId;
    private String userName;
private String userEmail;
private String userPhone;

private String writerFirebaseUid;




public Long getUserOrderid() {
    return UserOrderid;
}
public void setUserOrderid(Long userOrderid) {
    UserOrderid = userOrderid;
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

public String getTypeOfWork() {
    return typeOfWork;
}
public void setTypeOfWork(String typeOfWork) {
    this.typeOfWork = typeOfWork;
}
public String getLanguageSelectedChips() {
    return languageSelectedChips;
}
public void setLanguageSelectedChips(String languageSelectedChips) {
    this.languageSelectedChips = languageSelectedChips;
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
public String getDeliveryOption() {
    return deliveryOption;
}
public void setDeliveryOption(String deliveryOption) {
    this.deliveryOption = deliveryOption;
}
public String getDeliveryPickupOption() {
    return deliveryPickupOption;
}
public void setDeliveryPickupOption(String deliveryPickupOption) {
    this.deliveryPickupOption = deliveryPickupOption;
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
public String getWriterAssignmentStatus() {
    return writerAssignmentStatus;
}
public void setWriterAssignmentStatus(String writerAssignmentStatus) {
    this.writerAssignmentStatus = writerAssignmentStatus;
}
public Long getAddressid() {
    return Addressid;
}
public void setAddressid(Long addressid) {
    Addressid = addressid;
}
public String getFullName() {
    return fullName;
}
public void setFullName(String fullName) {
    this.fullName = fullName;
}
public String getMobileNumber() {
    return mobileNumber;
}
public void setMobileNumber(String mobileNumber) {
    this.mobileNumber = mobileNumber;
}
public String getPincode() {
    return pincode;
}
public void setPincode(String pincode) {
    this.pincode = pincode;
}
public String getHouseNo() {
    return houseNo;
}
public void setHouseNo(String houseNo) {
    this.houseNo = houseNo;
}
public String getLocality() {
    return locality;
}
public void setLocality(String locality) {
    this.locality = locality;
}
public String getCity() {
    return city;
}
public void setCity(String city) {
    this.city = city;
}
public String getState() {
    return state;
}
public void setState(String state) {
    this.state = state;
}
public String getSaveAs() {
    return saveAs;
}
public void setSaveAs(String saveAs) {
    this.saveAs = saveAs;
}
public Long getUserId() {
    return userId;
}
public void setUserId(Long userId) {
    this.userId = userId;
}
public String getUserName() {
    return userName;
}
public void setUserName(String userName) {
    this.userName = userName;
}
public String getUserEmail() {
    return userEmail;
}
public void setUserEmail(String userEmail) {
    this.userEmail = userEmail;
}
public String getUserPhone() {
    return userPhone;
}
public void setUserPhone(String userPhone) {
    this.userPhone = userPhone;
}

public String getUserFirebaseUid() {
    return userFirebaseUid;
}
public void setUserFirebaseUid(String userFirebaseUid) {
    this.userFirebaseUid = userFirebaseUid;
}
public String getWriterFirebaseUid() {
    return writerFirebaseUid;
}
public void setWriterFirebaseUid(String writerFirebaseUid) {
    this.writerFirebaseUid = writerFirebaseUid;
}
public Integer getUserFilePageCount() {
    return userFilePageCount;
}
public void setUserFilePageCount(Integer userFilePageCount) {
    this.userFilePageCount = userFilePageCount;
}
  

}
