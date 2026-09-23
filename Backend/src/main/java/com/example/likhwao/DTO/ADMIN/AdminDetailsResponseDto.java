package com.example.likhwao.DTO.ADMIN;

import java.time.LocalDateTime;

import com.example.likhwao.Entity.ADMIN.AdminDetailsEntity;

public class AdminDetailsResponseDto {

    private Long id;

    private String firebaseUid;

    private String email;

    private String name;

    private String phone;

    private String role;

    private Boolean detailsCompleted;

    private LocalDateTime createdAt;

    public AdminDetailsResponseDto() {
    }

    public AdminDetailsResponseDto(AdminDetailsEntity admin) {
        this.id = admin.getId();
        this.firebaseUid = admin.getFirebaseUid();
        this.email = admin.getEmail();
        this.name = admin.getName();
        this.phone = admin.getPhone();
        this.role = admin.getRole();
        this.detailsCompleted = admin.getDetailsCompleted();
        this.createdAt = admin.getCreatedAt();
    }

    public Long getId() {
        return id;
    }

    public String getFirebaseUid() {
        return firebaseUid;
    }

    public String getEmail() {
        return email;
    }

    public String getName() {
        return name;
    }

    public String getPhone() {
        return phone;
    }

    public String getRole() {
        return role;
    }

    public Boolean getDetailsCompleted() {
        return detailsCompleted;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setFirebaseUid(String firebaseUid) {
        this.firebaseUid = firebaseUid;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public void setDetailsCompleted(Boolean detailsCompleted) {
        this.detailsCompleted = detailsCompleted;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}