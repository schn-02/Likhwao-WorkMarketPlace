package com.example.likhwao.Entity.WRITER;

import java.sql.Date;

import org.hibernate.annotations.ManyToAny;

import com.example.likhwao.Entity.USER.UserDetailsEntity;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

@Entity
public class WriterWorkEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long writerWorkId;

    @ManyToOne
    @JoinColumn(name ="user_id")
    public UserDetailsEntity user;

    @ManyToOne
    @JoinColumn(name="user_order_id")
     public  UserOrdersDetailsEntity userOrder;

  public String filePath;
 public  String fileName;
 public  Long fileSize;
 public int filePageCount;

 @ManyToOne
 @JoinColumn(name = "writer_id")
 public WriterDetailsEntity writer;

  public String cancellationReason;

 public  Date orderCreatedAt;
 public  Date orderCompletedAt_REVIEW;
  public String  writerAssignmentStatus;
  public String writerSuggestionText;

  public String UserRequestChangeDescription;




  


  public Long getWriterWorkId() {
    return writerWorkId;
  }
  public void setWriterWorkId(Long writerWorkId) {
    this.writerWorkId = writerWorkId;
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
  public Date getOrderCompletedAt_REVIEW() {
    return orderCompletedAt_REVIEW;
  }
  public void setOrderCompletedAt_REVIEW(Date orderCompletedAt_REVIEW) {
    this.orderCompletedAt_REVIEW = orderCompletedAt_REVIEW;
  }
  public String getWriterAssignmentStatus() {
    return writerAssignmentStatus;
  }
  public void setWriterAssignmentStatus(String writerAssignmentStatus) {
    this.writerAssignmentStatus = writerAssignmentStatus;
  }
  public String getWriterSuggestionText() {
    return writerSuggestionText;
  }
  public void setWriterSuggestionText(String writerSuggestionText) {
    this.writerSuggestionText = writerSuggestionText;
  }

  
  public UserDetailsEntity getUser() {
    return user;
  }
  public void setUser(UserDetailsEntity user) {
    this.user = user;
  }
  public UserOrdersDetailsEntity getUserOrder() {
    return userOrder;
  }
  public void setUserOrder(UserOrdersDetailsEntity userOrder) {
    this.userOrder = userOrder;
  }
  public WriterDetailsEntity getWriter() {
    return writer;
  }
  public void setWriter(WriterDetailsEntity writer) {
    this.writer = writer;
  }
  public WriterWorkEntity() {
  }
  public String getFilePath() {
    return filePath;
  }
  public void setFilePath(String filePath) {
    this.filePath = filePath;
  }
  public String getUserRequestChangeDescription() {
    return UserRequestChangeDescription;
  }
  public void setUserRequestChangeDescription(String userRequestChangeDescription) {
    UserRequestChangeDescription = userRequestChangeDescription;
  }
  
  
}
