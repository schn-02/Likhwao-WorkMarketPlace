package com.example.likhwao.Model;

import java.sql.Date;

public class WriterWorkModel {
    

    public  Long userId;
    public  Long UserOrderId;

  public String fileUrl;
 public  String fileName;
 public  Long fileSize;
 public int filePageCount;
 public Long writerId;
  public String cancellationReason;

 public  Date orderCreatedAt;
 public  Date orderCompletedAt;
  public String  writerAssignmentStatus;
  public String writerSuggestionText;

  public Long getUserOrderId() {
    return UserOrderId;
  }
  public void setUserOrderId(Long userOrderId) {
    UserOrderId = userOrderId;
  }
  public String getFileUrl() {
    return fileUrl;
  }
  public void setFileUrl(String fileUrl) {
    this.fileUrl = fileUrl;
  }
  public String getFileName() {
    return fileName;
  }
  public void setFileName(String fileName) {
    this.fileName = fileName;
  }
  public Long getFileSize() {
    return fileSize;
  }
  public void setFileSize(Long fileSize) {
    this.fileSize = fileSize;
  }
  public int getFilePageCount() {
    return filePageCount;
  }
  public void setFilePageCount(int filePageCount) {
    this.filePageCount = filePageCount;
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
  public Date getOrderCreatedAt() {
    return orderCreatedAt;
  }
  public void setOrderCreatedAt(Date orderCreatedAt) {
    this.orderCreatedAt = orderCreatedAt;
  }
  public Date getOrderCompletedAt() {
    return orderCompletedAt;
  }
  public void setOrderCompletedAt(Date orderCompletedAt) {
    this.orderCompletedAt = orderCompletedAt;
  }
  public String getWriterAssignmentStatus() {
    return writerAssignmentStatus;
  }
  public void setWriterAssignmentStatus(String writerAssignmentStatus) {
    this.writerAssignmentStatus = writerAssignmentStatus;
  }
  public WriterWorkModel() {
  }
  public String getWriterSuggestionText() {
    return writerSuggestionText;
  }
  public void setWriterSuggestionText(String writerSuggestionText) {
    this.writerSuggestionText = writerSuggestionText;
  }
  

  public Long getUserId() {
    return userId;
  }
  public void setUserId(Long userId) {
    this.userId = userId;
  }
 

  
}
