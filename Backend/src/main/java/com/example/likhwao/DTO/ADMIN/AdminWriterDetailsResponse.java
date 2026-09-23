package com.example.likhwao.DTO.ADMIN;

import java.time.LocalDateTime;


public class AdminWriterDetailsResponse {



     private Long id;
    private String firebaseUid;
    private String email;
    private String name;
    private String countryCode;
    private String countryName;
    private String phoneNumber;
    private boolean emailVerified;
    private boolean detailsCompleted;
    private Boolean blocked;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer totalOrders;
    private Integer totalEarnings;
    private String role;
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getFirebaseUid() {
        return firebaseUid;
    }
    public void setFirebaseUid(String firebaseUid) {
        this.firebaseUid = firebaseUid;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
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
    public String getPhoneNumber() {
        return phoneNumber;
    }
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    public boolean isEmailVerified() {
        return emailVerified;
    }
    public void setEmailVerified(boolean emailVerified) {
        this.emailVerified = emailVerified;
    }
    public boolean isDetailsCompleted() {
        return detailsCompleted;
    }
    public void setDetailsCompleted(boolean detailsCompleted) {
        this.detailsCompleted = detailsCompleted;
    }
    public Boolean getBlocked() {
        return blocked;
    }
    public void setBlocked(Boolean blocked) {
        this.blocked = blocked;
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
    public Integer getTotalOrders() {
        return totalOrders;
    }
    public void setTotalOrders(Integer totalOrders) {
        this.totalOrders = totalOrders;
    }
    public Integer getTotalEarnings() {
        return totalEarnings;
    }
    public void setTotalEarnings(Integer totalEarnings) {
        this.totalEarnings = totalEarnings;
    }
    public String getRole() {
        return role;
    }
    public void setRole(String role) {
        this.role = role;
    }
}
