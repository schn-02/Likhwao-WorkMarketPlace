package com.example.likhwao.Model;

public class AuthModel {

    private String firebaseUid;
    private String email;
    private String name;
    private String firebaseIdToken;

    // Main generated/final device key from Flutter
    private String deviceId;

    // Device details
    private String deviceModel;
    private String androidId;
    private String firebaseInstallationId;
    private String brand;
    private String manufacturer;

    private String countryCode;
    private String countryName;
    private String phoneNumber;

    private boolean rooted;
    private boolean emulator;

    private boolean emailVerified;
    private boolean detailsCompleted;

    private String appHash;

    public AuthModel() {
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

	public String getFirebaseIdToken() {
        return firebaseIdToken;
    }

    public void setFirebaseIdToken(String firebaseIdToken) {
        this.firebaseIdToken = firebaseIdToken;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
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

    public String getAppHash() {
        return appHash;
    }

    public void setAppHash(String appHash) {
        this.appHash = appHash;
    }

    @Override
    public String toString() {
        return "AuthModel{" +
                "firebaseUid='" + firebaseUid + '\'' +
                ", email='" + email + '\'' +
                ", name='" + name + '\'' +
                ", firebaseIdToken='" + firebaseIdToken + '\'' +
                ", deviceId='" + deviceId + '\'' +
                ", deviceModel='" + deviceModel + '\'' +
                ", androidId='" + androidId + '\'' +
                ", firebaseInstallationId='" + firebaseInstallationId + '\'' +
                ", brand='" + brand + '\'' +
                ", manufacturer='" + manufacturer + '\'' +
                ", countryCode='" + countryCode + '\'' +
                ", countryName='" + countryName + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", rooted=" + rooted +
                ", emulator=" + emulator +
                ", emailVerified=" + emailVerified +
                ", detailsCompleted=" + detailsCompleted +
                ", appHash='" + appHash + '\'' +
                '}';
    }
}