package com.example.likhwao.Entity.ADMIN;

import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

@Entity
@Table(name = "admin_details")
public class AdminDetailsEntity {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

private String firebaseUid;

private String email;

private String name;

private String phone;

private String role;

private Boolean detailsCompleted =false;

private LocalDateTime createdAt;

  @PrePersist
    public void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }

        if (detailsCompleted == null) {
            detailsCompleted = false;
        }

        if (role == null) {
            role = "ADMIN";
        }
    }

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

public String getPhone() {
    return phone;
}

public void setPhone(String phone) {
    this.phone = phone;
}

public String getRole() {
    return role;
}

public void setRole(String role) {
    this.role = role;
}

public Boolean getDetailsCompleted() {
    return detailsCompleted;
}

public void setDetailsCompleted(Boolean detailsCompleted) {
    this.detailsCompleted = detailsCompleted;
}

public LocalDateTime getCreatedAt() {
    return createdAt;
}

public void setCreatedAt(LocalDateTime createdAt) {
    this.createdAt = createdAt;
}





}
