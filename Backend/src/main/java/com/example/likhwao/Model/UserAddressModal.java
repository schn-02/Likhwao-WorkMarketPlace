package com.example.likhwao.Model;

public class UserAddressModal {


    private String fullName;
    private String mobileNumber;
    private String pincode;
    private String houseNo;
    private String locality;
    private String city;
    private String state;
    private String saveAs;
    public String getFullName() {
        return fullName;
    }
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    public String getMobileNumber() {
        return mobileNumber;
    }
    public void setMobileNumber(String mobileNumber) {
        this.mobileNumber = mobileNumber;
    }
    public String getPincode() {
        return pincode;
    }
    public void setPincode(String pincode) {
        this.pincode = pincode;
    }
    public String getHouseNo() {
        return houseNo;
    }
    public void setHouseNo(String houseNo) {
        this.houseNo = houseNo;
    }
    public String getLocality() {
        return locality;
    }
    public void setLocality(String locality) {
        this.locality = locality;
    }
    public String getCity() {
        return city;
    }
    public void setCity(String city) {
        this.city = city;
    }
    public String getState() {
        return state;
    }
    public void setState(String state) {
        this.state = state;
    }
    public String getSaveAs() {
        return saveAs;
    }
    public void setSaveAs(String saveAs) {
        this.saveAs = saveAs;
    }
    public UserAddressModal() {
    }
    @Override
    public String toString() {
        return "UserAddressModal [fullName=" + fullName + ", mobileNumber=" + mobileNumber + ", pincode=" + pincode
                + ", houseNo=" + houseNo + ", locality=" + locality + ", city=" + city + ", state=" + state
                + ", saveAs=" + saveAs + "]";
    }
    
}
