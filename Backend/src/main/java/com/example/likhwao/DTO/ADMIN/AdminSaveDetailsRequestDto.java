package com.example.likhwao.DTO.ADMIN;

public class AdminSaveDetailsRequestDto {
    private String name;

    private String phone;

    public AdminSaveDetailsRequestDto() {
    }

    public AdminSaveDetailsRequestDto(String name, String phone) {
        this.name = name;
        this.phone = phone;
    }

    public String getName() {
        return name;
    }

    public String getPhone() {
        return phone;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
}