package com.example.likhwao.Entity.USER;

import java.time.LocalDate;
import java.time.LocalDateTime;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;




@Entity
@EntityListeners(AuditingEntityListener.class)
public class UserOrdersDetailsEntity {

      @Id
      @GeneratedValue(strategy = GenerationType.IDENTITY)
      private Long id;

      @ManyToOne(fetch = FetchType.LAZY)
      @JoinColumn(name = "user_id" , nullable = false)
      private UserDetailsEntity user;


      //file info
        private String fileName;
    
       private String userFilePath;


    private Long fileSize;
    private Integer filePageCount;

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
    private String userName;
    private String userNumber;


    
    //Address
    private String  deliveryAddress;
    private Double latitude;
    private Double longitude;

   //Amount
    private Integer orderPageCountAmount;
    private Integer urgencyAmount;
    private Integer deliveryChargesAmount;
    private Integer platformFeeAmount;
    private Integer noteBookChargesAmount;
    private Integer totalOrderAmount;


    //Payment
    private String razorpayOrderId;
private String paymentId;
private String paymentStatus;

private String paymentMethod;   // UPI / CARD
private String paymentBank; 

//Refund
private String refundStatus;   // UPI / CARD
private String refundId; 


private String orderStatus;

@ManyToOne
@JoinColumn(name = "writer_id")
private WriterDetailsEntity writer;

private String cancellationReason;


@CreatedDate
@Column(updatable = false)
private LocalDateTime orderCreatedAt;
private LocalDateTime orderCompletedAt;

private String writerAssignmentStatus ;

private String userFirebaseUid ;
private String writerFirebaseUid ;








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
    public UserDetailsEntity getUser() {
    return user;
}
public void setUser(UserDetailsEntity user) {
    this.user = user;
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
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getFileName() {
        return fileName;
    }
    public void setFileName(String fileName) {
        this.fileName = fileName;
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
    public UserOrdersDetailsEntity() {
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
    public String getWriterAssignmentStatus() {
        return writerAssignmentStatus;
    }
    public void setWriterAssignmentStatus(String writerAssignmentStatus) {
        this.writerAssignmentStatus = writerAssignmentStatus;
    }
    public WriterDetailsEntity getWriter() {
        return writer;
    }
    public void setWriter(WriterDetailsEntity writer) {
        this.writer = writer;
    }
   
 
  


}
