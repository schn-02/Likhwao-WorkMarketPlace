package com.example.likhwao.Model;

import java.time.LocalDate;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.persistence.CascadeType;
import jakarta.persistence.OneToMany;

public class UserOrderDetailsModal {

    @JsonProperty("UserOrderId")
    private Long id;

    @JsonProperty("writerWorkId")
    private Long writerWorkId;

       private String userFileName;
       private String userFileUrl;

       private String userFilePath;


    private Long userFileSize;

    @JsonProperty("userFilePageCount")
    private Integer userFilePageCount;


   private String writerFileUrl;
  private String  writerFilePath;
  private String  writerFileName;

   private Integer  writerFileSize;
  private Integer writerFilePageCount;

    // Order details
    private String typeOfWork;
    private String languageSelectedChips;
    private String selectedInkColor;
    private String selectedNotebook;
    private String writerSuggestionText;
    private String workToBeDone;
    private String deliveryPickupOption;
    private String selectedDeadLineUrgency;
    private LocalDate selectedDate;

   


    // Address list
    private List<UserAddressModal> addressList;

    private Integer orderPageCountAmount;
    private Integer urgencyAmount;
    private Integer deliveryChargesAmount;
    private Integer platformFeeAmount;
    private Integer noteBookChargesAmount;
    private Integer totalOrderAmount;

    private String writerAssignmentStatus ;

    private String userFirebaseUid ;
    private String writerFirebaseUid ;
    
    private String userName ;
    private String userNumber ;

    private String UserRequestChangeDescription;


    

    


    public String getWriterFileUrl() {
        return writerFileUrl;
    }
    public void setWriterFileUrl(String writerFileUrl) {
        this.writerFileUrl = writerFileUrl;
    }
    public String getWriterFilePath() {
        return writerFilePath;
    }
    public void setWriterFilePath(String writerFilePath) {
        this.writerFilePath = writerFilePath;
    }
    public String getWriterFileName() {
        return writerFileName;
    }
    public void setWriterFileName(String writerFileName) {
        this.writerFileName = writerFileName;
    }
    public Integer getWriterFileSize() {
        return writerFileSize;
    }
    public void setWriterFileSize(Integer writerFileSize) {
        this.writerFileSize = writerFileSize;
    }
    public Integer getWriterFilePageCount() {
        return writerFilePageCount;
    }
    public void setWriterFilePageCount(Integer writerFilePageCount) {
        this.writerFilePageCount = writerFilePageCount;
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
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getWriterAssignmentStatus() {
        return writerAssignmentStatus;
    }
    public void setWriterAssignmentStatus(String writerAssignmentStatus) {
        this.writerAssignmentStatus = writerAssignmentStatus;
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
 
    public List<UserAddressModal> getAddressList() {
        return addressList;
    }
    public void setAddressList(List<UserAddressModal> addressList) {
        this.addressList = addressList;
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
    public UserOrderDetailsModal() {
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
    public Long getWriterWorkId() {
        return writerWorkId;
    }
    public void setWriterWorkId(Long writerWorkId) {
        this.writerWorkId = writerWorkId;
    }
    public String getWorkToBeDone() {
        return workToBeDone;
    }
    public void setWorkToBeDone(String workToBeDone) {
        this.workToBeDone = workToBeDone;
    }
    public String getUserFileName() {
        return userFileName;
    }
    public void setUserFileName(String userFileName) {
        this.userFileName = userFileName;
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
    public String getUserRequestChangeDescription() {
        return UserRequestChangeDescription;
    }
    public void setUserRequestChangeDescription(String userRequestChangeDescription) {
        UserRequestChangeDescription = userRequestChangeDescription;
    }
    
   


}
