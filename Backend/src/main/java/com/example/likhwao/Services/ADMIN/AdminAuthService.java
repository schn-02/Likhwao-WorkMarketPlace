package com.example.likhwao.Services.ADMIN;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.likhwao.DTO.ADMIN.AdminSaveDetailsRequestDto;
import com.example.likhwao.Entity.ADMIN.AdminDetailsEntity;
import com.example.likhwao.Repository.ADMIN.AdminDetailsRepository;

@Service
public class AdminAuthService {

    @Autowired
    private AdminDetailsRepository adminDetailsRepository;

    public boolean checkAdminExists(String email) {
        return adminDetailsRepository.existsByEmail(email);
    }

    public Optional<AdminDetailsEntity> findByFirebaseUid(String firebaseUid) {
        return adminDetailsRepository.findByFirebaseUid(firebaseUid);
    }

    public AdminDetailsEntity saveOrUpdateAdminDetails(
            String firebaseUid,
            String email,
            AdminSaveDetailsRequestDto request
    ) {
        AdminDetailsEntity admin = adminDetailsRepository
                .findByFirebaseUid(firebaseUid)
                .orElse(new AdminDetailsEntity());

        admin.setFirebaseUid(firebaseUid);
        admin.setEmail(email);
        admin.setName(request.getName());
        admin.setPhone(request.getPhone());
        admin.setRole("ADMIN");
        admin.setDetailsCompleted(true);

        return adminDetailsRepository.save(admin);
    }
}