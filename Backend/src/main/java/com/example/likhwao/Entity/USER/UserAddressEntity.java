package com.example.likhwao.Entity.USER;


import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;



@Entity
public class UserAddressEntity {


       @Id
       @GeneratedValue(strategy = GenerationType.IDENTITY)
       private Long id;
        private String fullName;
    private String mobileNumber;
    private String pincode;
    private String houseNo;
    private String locality;
    private String city;
    private String state;
    private String saveAs;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private UserDetailsEntity user;
    
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
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
   
    @Override
    public String toString() {
        return "UserAddressEntity [id=" + id + ", fullName=" + fullName + ", mobileNumber=" + mobileNumber
                + ", pincode=" + pincode + ", houseNo=" + houseNo + ", locality=" + locality + ", city=" + city
                + ", state=" + state + ", saveAs=" + saveAs + ", order=" + user + "]";
    }
    public UserAddressEntity() {
    }
    public UserDetailsEntity getUser() {
        return user;
    }
    public void setUser(UserDetailsEntity user) {
        this.user = user;
    }

    
}
