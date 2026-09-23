package com.example.likhwao.Entity;

import jakarta.persistence.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@EntityListeners(AuditingEntityListener.class)
@Table(
        name = "device_account_lock",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_device_app_type",
                        columnNames = {"device_id", "app_type"}
                )
        }
)
public class DeviceAccountLockEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Final device key sent from app
    @Column(name = "device_id", nullable = false)
    private String deviceId;

    // USER_APP or WRITER_APP
    @Column(name = "app_type", nullable = false)
    private String appType;

    // Account locked with this device + app type
    @Column(nullable = false)
    private String firebaseUid;

    @Column(nullable = false)
    private String email;

    private String deviceModel;

    private String androidId;

    private String firebaseInstallationId;

    private String brand;

    private String manufacturer;

    @Column(nullable = false)
    private boolean rooted = false;

    @Column(nullable = false)
    private boolean emulator = false;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    public DeviceAccountLockEntity() {
    }

    public DeviceAccountLockEntity(Long id, String deviceId, String appType, String firebaseUid,
                                   String email, String deviceModel, String androidId,
                                   String firebaseInstallationId, String brand, String manufacturer,
                                   boolean rooted, boolean emulator,
                                   LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.deviceId = deviceId;
        this.appType = appType;
        this.firebaseUid = firebaseUid;
        this.email = email;
        this.deviceModel = deviceModel;
        this.androidId = androidId;
        this.firebaseInstallationId = firebaseInstallationId;
        this.brand = brand;
        this.manufacturer = manufacturer;
        this.rooted = rooted;
        this.emulator = emulator;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getId() {
        return id;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public String getAppType() {
        return appType;
    }

    public void setAppType(String appType) {
        this.appType = appType;
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
    
    public String getDeviceModel() {
        return deviceModel;
    }

    public void setDeviceModel(String deviceModel) {
        this.deviceModel = deviceModel;
    }

    public String getAndroidId() {
        return androidId;
    }

    public void setAndroidId(String androidId) {
        this.androidId = androidId;
    }

    public String getFirebaseInstallationId() {
        return firebaseInstallationId;
    }

    public void setFirebaseInstallationId(String firebaseInstallationId) {
        this.firebaseInstallationId = firebaseInstallationId;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }
    
    public String getManufacturer() {
        return manufacturer;
    }

    public void setManufacturer(String manufacturer) {
        this.manufacturer = manufacturer;
    }

    public boolean isRooted() {
        return rooted;
    }

    public void setRooted(boolean rooted) {
        this.rooted = rooted;
    }

    public boolean isEmulator() {
        return emulator;
    }

    public void setEmulator(boolean emulator) {
        this.emulator = emulator;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
}