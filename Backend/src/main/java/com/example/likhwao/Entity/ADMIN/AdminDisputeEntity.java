package com.example.likhwao.Entity.ADMIN;


import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

@Entity
@Table(name = "order_disputes")
public class AdminDisputeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long orderId;

    private String userFirebaseUid;

    private String writerFirebaseUid;

    private String reason;

    @Column(length = 2000)
    private String message;

    private String disputeStatus; 
    // OPEN, ADMIN_REVIEWING, WAITING_USER_REPLY, WAITING_WRITER_REPLY, REVISION_REQUESTED, RESOLVED, REJECTED

    private String raisedBy; 
    // USER

    private String adminFirebaseUid;

    private String orderStatusAtDispute; // REVIEW
private String writerSubmissionVersion; // v1, v2, v3

    @Column(length = 2000)
    private String adminDecisionNote;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    private LocalDateTime resolvedAt;


    private String raisedByFirebaseUid;

    

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
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

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getDisputeStatus() {
        return disputeStatus;
    }

    public void setDisputeStatus(String disputeStatus) {
        this.disputeStatus = disputeStatus;
    }

    public String getRaisedBy() {
        return raisedBy;
    }

    public void setRaisedBy(String raisedBy) {
        this.raisedBy = raisedBy;
    }

    public String getAdminFirebaseUid() {
        return adminFirebaseUid;
    }

    public void setAdminFirebaseUid(String adminFirebaseUid) {
        this.adminFirebaseUid = adminFirebaseUid;
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

    public String getAdminDecisionNote() {
        return adminDecisionNote;
    }

    public void setAdminDecisionNote(String adminDecisionNote) {
        this.adminDecisionNote = adminDecisionNote;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public LocalDateTime getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(LocalDateTime resolvedAt) {
        this.resolvedAt = resolvedAt;
    }

    public String getRaisedByFirebaseUid() {
        return raisedByFirebaseUid;
    }

    public void setRaisedByFirebaseUid(String raisedByFirebaseUid) {
        this.raisedByFirebaseUid = raisedByFirebaseUid;
    }


    
}