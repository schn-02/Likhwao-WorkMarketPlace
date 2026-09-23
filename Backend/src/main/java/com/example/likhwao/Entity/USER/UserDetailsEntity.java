package com.example.likhwao.Entity.USER;

import jakarta.persistence.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@EntityListeners(AuditingEntityListener.class)
@Table(name = "user_details")
public class UserDetailsEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Firebase UID should be unique for every account
    @Column(unique = true, nullable = false)
    private String firebaseUid;

    // Email should be unique for every user account
    @Column(unique = true, nullable = false)
    private String email;

    private String name;

    @Column(unique = true, nullable = false)
    private String phoneNumber;

    private String countryCode;

    private String countryName;

    @Column(nullable = false)
    private boolean emailVerified = false;

    @Column(nullable = false)
    private boolean detailsCompleted = false;

    @Column(nullable = false)
    private Boolean blocked = false;

    @Column(nullable = false)
    private Integer totalOrders = 0;

    @Column(nullable = false)
    private String role = "USER";

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    private Integer totalSpent = 0;

    private Double averageRating = 0.0;
private Integer totalReviews = 0;


private String blockReason;
private Integer cancelledOrders = 0;




    public String getBlockReason() {
    return blockReason;
}

public void setBlockReason(String blockReason) {
    this.blockReason = blockReason;
}

public Integer getCancelledOrders() {
    return cancelledOrders;
}

public void setCancelledOrders(Integer cancelledOrders) {
    this.cancelledOrders = cancelledOrders;
}

    public Double getAverageRating() {
    return averageRating;
}

public void setAverageRating(Double averageRating) {
    this.averageRating = averageRating;
}

public Integer getTotalReviews() {
    return totalReviews;
}

public void setTotalReviews(Integer totalReviews) {
    this.totalReviews = totalReviews;
}

    public UserDetailsEntity() {
    }

    public UserDetailsEntity(Long id, String firebaseUid, String email, String name, String phoneNumber,
                             String countryCode, String countryName, boolean emailVerified,
                             boolean detailsCompleted, Boolean blocked, Integer totalOrders,
                             String role, LocalDateTime createdAt, LocalDateTime updatedAt , Integer totalSpent) {
        this.id = id;
        this.firebaseUid = firebaseUid;
        this.email = email;
        this.name = name;
        this.phoneNumber = phoneNumber;
        this.countryCode = countryCode;
        this.countryName = countryName;
        this.emailVerified = emailVerified;
        this.detailsCompleted = detailsCompleted;
        this.blocked = blocked;
        this.totalOrders = totalOrders;
        this.role = role;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.totalSpent = totalSpent;
    }

    

    public void setId(Long id) {
        this.id = id;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getTotalSpent() {
        return totalSpent;
    }

    public void setTotalSpent(Integer totalSpent) {
        this.totalSpent = totalSpent;
    }

    public Long getId() {
        return id;
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

	public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
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

    public Integer getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(Integer totalOrders) {
        this.totalOrders = totalOrders;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }


}