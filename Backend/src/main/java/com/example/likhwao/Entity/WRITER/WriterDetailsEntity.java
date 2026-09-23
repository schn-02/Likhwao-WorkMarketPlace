package com.example.likhwao.Entity.WRITER;

import java.time.LocalDateTime;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@EntityListeners(AuditingEntityListener.class)
@Table(name = "writer_details")
public class WriterDetailsEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String firebaseUid;

    @Column(unique = true, nullable = false)
    private String email;

    private String name;

    private String countryCode;

    private String countryName;

    @Column(unique = true, nullable = false)
    private String phoneNumber;

    @Column(nullable = false)
    private boolean emailVerified = false;

    @Column(nullable = false)
    private boolean detailsCompleted = false;

    @Column(nullable = false)
    private Boolean blocked = false;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @Column(nullable = false)
    private Integer totalOrders = 0;

    @Column(nullable = false)
    private String role = "WRITER";


    private Integer writerTotalEarning =0;


    private Double averageRating = 0.0;
private Integer totalReviews = 0;


  
private Integer cancelledOrders = 0;
private Integer totalRequestChanges = 0;
private Double successRate = 0.0;

    

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



public Integer getCancelledOrders() {
    return cancelledOrders;
}

public void setCancelledOrders(Integer cancelledOrders) {
    this.cancelledOrders = cancelledOrders;
}

public Integer getTotalRequestChanges() {
    return totalRequestChanges;
}

public void setTotalRequestChanges(Integer totalRequestChanges) {
    this.totalRequestChanges = totalRequestChanges;
}


public Double getSuccessRate() {
    return successRate;
}

public void setSuccessRate(Double successRate) {
    this.successRate = successRate;
}

    public WriterDetailsEntity() {
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

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
    
    @Override
    public String toString() {
        return "WriterDetailsEntity{" +
                "id=" + id +
                ", firebaseUid='" + firebaseUid + '\'' +
                ", email='" + email + '\'' +
                ", name='" + name + '\'' +
                ", countryCode='" + countryCode + '\'' +
                ", countryName='" + countryName + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", emailVerified=" + emailVerified +
                ", detailsCompleted=" + detailsCompleted +
                ", blocked=" + blocked +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                ", totalOrders=" + totalOrders +
                ", role='" + role + '\'' +
                '}';
    }

    public Integer getWriterTotalEarning() {
        return writerTotalEarning;
    }

    public void setWriterTotalEarning(Integer writerTotalEarning) {
        this.writerTotalEarning = writerTotalEarning;
    }
}