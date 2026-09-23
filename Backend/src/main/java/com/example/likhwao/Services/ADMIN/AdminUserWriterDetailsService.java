package com.example.likhwao.Services.ADMIN;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.likhwao.DTO.ADMIN.AdminUserDetialsResponse;
import com.example.likhwao.DTO.ADMIN.AdminUserWriterDetailsDto;
import com.example.likhwao.DTO.ADMIN.AdminWriterDetailsResponse;
import com.example.likhwao.Entity.USER.UserDetailsEntity;
import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;
import com.example.likhwao.Repository.ADMIN.AdminDetailsRepository;
import com.example.likhwao.Repository.USER.UserDetailsEntityRepository;
import com.example.likhwao.Repository.WRITER.WritersDetailsEntityRepository;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;

import jakarta.transaction.Transactional;

@Service
public class AdminUserWriterDetailsService {

    @Autowired
    private UserDetailsEntityRepository uer;

    @Autowired
    private WritersDetailsEntityRepository wer;

    @Autowired
    private AdminDetailsRepository adminRepository;

    @Transactional
    public AdminUserWriterDetailsDto fetchDetails(String token) {

        try {
            if (token == null || token.isBlank() || !token.startsWith("Bearer ")) {
                throw new RuntimeException("Invalid token");
            }

            token = token.substring(7);

            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(token);
            String adminFirebaseUid = decodedToken.getUid();

            
            adminRepository.findByFirebaseUid(adminFirebaseUid)
                   .orElseThrow(() -> new RuntimeException("Unauthorized admin"));

            List<UserDetailsEntity> users = uer.findAll();
            List<WriterDetailsEntity> writers = wer.findAll();

            List<AdminUserDetialsResponse> userResponses = users.stream()
                    .map(this::mapUserToResponse)
                    .collect(Collectors.toList());

            List<AdminWriterDetailsResponse> writerResponses = writers.stream()
                    .map(this::mapWriterToResponse)
                    .collect(Collectors.toList());

            AdminUserWriterDetailsDto dto = new AdminUserWriterDetailsDto();
            dto.setUsers(userResponses);
            dto.setWriters(writerResponses);

            return dto;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to fetch user and writer details", e);
        }
    }

    private AdminUserDetialsResponse mapUserToResponse(UserDetailsEntity u) {
        AdminUserDetialsResponse response = new AdminUserDetialsResponse();

        response.setId(u.getId());
        response.setBlocked(u.getBlocked());
        response.setCountryCode(u.getCountryCode());
        response.setCountryName(u.getCountryName());
        response.setCreatedAt(u.getCreatedAt());
        response.setDetailsCompleted(u.isDetailsCompleted());
        response.setEmailVerified(u.isEmailVerified());
        response.setEmail(u.getEmail());
        response.setFirebaseUid(u.getFirebaseUid());
        response.setPhoneNumber(u.getPhoneNumber());
        response.setTotalOrders(u.getTotalOrders());
        response.setTotalSpent(u.getTotalSpent());
        response.setRole(u.getRole());
        response.setUpdatedAt(u.getUpdatedAt());
        response.setName(u.getName());

        return response;
    }

    private AdminWriterDetailsResponse mapWriterToResponse(WriterDetailsEntity w) {
        AdminWriterDetailsResponse response = new AdminWriterDetailsResponse();

        response.setId(w.getId());
        response.setBlocked(w.getBlocked());
        response.setCountryCode(w.getCountryCode());
        response.setCountryName(w.getCountryName());
        response.setCreatedAt(w.getCreatedAt());
        response.setDetailsCompleted(w.isDetailsCompleted());
        response.setEmailVerified(w.isEmailVerified());
        response.setEmail(w.getEmail());
        response.setFirebaseUid(w.getFirebaseUid());
        response.setPhoneNumber(w.getPhoneNumber());
        response.setTotalOrders(w.getTotalOrders());
        response.setTotalEarnings(w.getWriterTotalEarning());
        response.setRole(w.getRole());
        response.setUpdatedAt(w.getUpdatedAt());
        response.setName(w.getName());

        return response;
    }
}