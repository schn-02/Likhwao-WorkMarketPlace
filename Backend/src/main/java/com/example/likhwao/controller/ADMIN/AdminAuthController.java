package com.example.likhwao.controller.ADMIN;

import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.DTO.ADMIN.AdminDetailsResponseDto;
import com.example.likhwao.DTO.ADMIN.AdminSaveDetailsRequestDto;
import com.example.likhwao.Entity.ADMIN.AdminDetailsEntity;
import com.example.likhwao.Services.ADMIN.AdminAuthService;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;

@RestController
@RequestMapping("/api/admin/auth")
public class AdminAuthController {

    @Autowired
    private AdminAuthService adminAuthService;

    @GetMapping("/check")
    public ResponseEntity<Boolean> checkAdminExists(
            @RequestParam String email
    ) {
        return ResponseEntity.ok(
                adminAuthService.checkAdminExists(email)
        );
    }

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentAdmin(
            @RequestHeader("Authorization") String authorizationHeader
    ) {
        try {
            FirebaseToken decodedToken = verifyFirebaseToken(authorizationHeader);

            String firebaseUid = decodedToken.getUid();

            Optional<AdminDetailsEntity> adminOpt =
                    adminAuthService.findByFirebaseUid(firebaseUid);

            if (adminOpt.isEmpty()) {
                return ResponseEntity.status(404).body(Map.of(
                        "message", "Admin details not found",
                        "firebaseUid", firebaseUid
                ));
            }

            AdminDetailsEntity admin = adminOpt.get();

            return ResponseEntity.ok(
                    new AdminDetailsResponseDto(admin)
            );

        } catch (Exception e) {
            return ResponseEntity.status(401).body(Map.of(
                    "message", "Invalid or expired token",
                    "error", e.getMessage()
            ));
        }
    }

    @PostMapping("/save-details")
    public ResponseEntity<?> saveAdminDetails(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody AdminSaveDetailsRequestDto request
    ) {
        try {
            FirebaseToken decodedToken = verifyFirebaseToken(authorizationHeader);

            String firebaseUid = decodedToken.getUid();
            String email = decodedToken.getEmail();

            AdminDetailsEntity savedAdmin =
                    adminAuthService.saveOrUpdateAdminDetails(
                            firebaseUid,
                            email,
                            request
                    );

            return ResponseEntity.ok(
                    new AdminDetailsResponseDto(savedAdmin)
            );

        } catch (Exception e) {
            return ResponseEntity.status(401).body(Map.of(
                    "message", "Unable to save admin details",
                    "error", e.getMessage()
            ));
        }
    }

    private FirebaseToken verifyFirebaseToken(String authorizationHeader) throws Exception {
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            throw new RuntimeException("Authorization header missing or invalid");
        }

        String token = authorizationHeader.replace("Bearer ", "").trim();

        return FirebaseAuth
                .getInstance()
                .verifyIdToken(token);
    }
}