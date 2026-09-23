package com.example.likhwao.DTO.ADMIN;

import java.time.LocalDateTime;
import java.util.List;

public class AdminUserWriterDetailsDto {
    

private List<AdminUserDetialsResponse> users;
    private List<AdminWriterDetailsResponse> writers;
    public List<AdminUserDetialsResponse> getUsers() {
        return users;
    }
    public void setUsers(List<AdminUserDetialsResponse> users) {
        this.users = users;
    }
    public List<AdminWriterDetailsResponse> getWriters() {
        return writers;
    }
    public void setWriters(List<AdminWriterDetailsResponse> writers) {
        this.writers = writers;
    }


    
    
}
