package com.example.likhwao.controller.ADMIN;

import com.example.likhwao.Entity.ADMIN.AdminDetailsEntity;
import com.example.likhwao.Repository.ADMIN.AdminDetailsRepository;
import com.example.likhwao.Services.ADMIN.AdminStorageSignedUrlService;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin/files")
public class AdminFileAccessController {

    private final AdminDetailsRepository adminDetailsEntityRepository;
    private final AdminStorageSignedUrlService storageSignedUrlService;

    public AdminFileAccessController(
            AdminDetailsRepository adminDetailsEntityRepository,
            AdminStorageSignedUrlService storageSignedUrlService
    ) {
        this.adminDetailsEntityRepository = adminDetailsEntityRepository;
        this.storageSignedUrlService = storageSignedUrlService;
    }

    @GetMapping("/{orderId}/writer-file-url")
    public ResponseEntity<?> getLatestWriterFileUrlForAdmin(
            @RequestHeader("Authorization") String token,
            @PathVariable Long orderId
    ) {
        try {
            FirebaseToken decodedToken = verifyFirebaseToken(token);
            String adminUid = decodedToken.getUid();

            if (!isAdmin(adminUid)) {
                return ResponseEntity.status(403).body("Only admin can access this file");
            }

            Firestore db = FirestoreClient.getFirestore();

            var orderDoc = db.collection("orders")
                    .document(orderId.toString())
                    .get()
                    .get();

            if (!orderDoc.exists()) {
                return ResponseEntity.status(404).body("Order not found in Firebase");
            }

            Map<String, Object> orderData = orderDoc.getData();

            if (orderData == null) {
                return ResponseEntity.status(404).body("Order data not found");
            }

            String filePath = getString(orderData, "latestSubmissionFilePath");

            if (filePath == null || filePath.isBlank()) {
                return ResponseEntity.status(404).body("Latest submission file path not found");
            }

            return ResponseEntity.ok(storageSignedUrlService.generateSignedUrl(filePath));

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(e.getMessage());
        }
    }

    @GetMapping("/{orderId}/user-file-url")
    public ResponseEntity<?> getUserFileUrlForAdmin(
            @RequestHeader("Authorization") String token,
            @PathVariable Long orderId
    ) {
        try {
            FirebaseToken decodedToken = verifyFirebaseToken(token);
            String adminUid = decodedToken.getUid();

            if (!isAdmin(adminUid)) {
                return ResponseEntity.status(403).body("Only admin can access this file");
            }

            Firestore db = FirestoreClient.getFirestore();

            var orderDoc = db.collection("orders")
                    .document(orderId.toString())
                    .get()
                    .get();

            if (!orderDoc.exists()) {
                return ResponseEntity.status(404).body("Order not found in Firebase");
            }

            Map<String, Object> orderData = orderDoc.getData();

            if (orderData == null) {
                return ResponseEntity.status(404).body("Order data not found");
            }

            String filePath = getString(orderData, "userFilePath");

            if (filePath == null || filePath.isBlank()) {
                filePath = getString(orderData, "userFilePath");
            }

            if (filePath == null || filePath.isBlank()) {
                return ResponseEntity.status(404).body("User file path not found");
            }

            return ResponseEntity.ok(storageSignedUrlService.generateSignedUrl(filePath));

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(e.getMessage());
        }
    }

    @GetMapping("/{orderId}/file-url-by-path")
public ResponseEntity<?> getFileUrlByPathForAdmin(
        @RequestHeader("Authorization") String token,
        @PathVariable Long orderId,
        @RequestParam String filePath
) {
    try {
        FirebaseToken decodedToken = verifyFirebaseToken(token);
        String adminUid = decodedToken.getUid();

        if (!isAdmin(adminUid)) {
            return ResponseEntity.status(403).body("Only admin can access this file");
        }

        if (filePath == null || filePath.isBlank()) {
            return ResponseEntity.status(400).body("File path missing");
        }

        Firestore db = FirestoreClient.getFirestore();

        var orderDoc = db.collection("orders")
                .document(orderId.toString())
                .get()
                .get();

        if (!orderDoc.exists()) {
            return ResponseEntity.status(404).body("Order not found in Firebase");
        }

        Map<String, Object> orderData = orderDoc.getData();

        if (orderData == null) {
            return ResponseEntity.status(404).body("Order data not found");
        }

        if (!isFilePathBelongsToOrder(db, orderId, orderData, filePath)) {
            return ResponseEntity.status(403).body("This file does not belong to this order");
        }

        return ResponseEntity.ok(storageSignedUrlService.generateSignedUrl(filePath));

    } catch (IllegalArgumentException e) {
        return ResponseEntity.status(400).body(e.getMessage());
    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.status(500).body(e.getMessage());
    }
}

    private FirebaseToken verifyFirebaseToken(String token) throws Exception {
        if (token == null || !token.startsWith("Bearer ")) {
            throw new IllegalArgumentException("INVALID TOKEN");
        }

        String idToken = token.substring(7);

        return FirebaseAuth.getInstance().verifyIdToken(idToken);
    }

    private boolean isAdmin(String firebaseUid) {
        if (firebaseUid == null || firebaseUid.isBlank()) {
            return false;
        }

        Optional<AdminDetailsEntity> optionalAdmin =
                adminDetailsEntityRepository.findByFirebaseUid(firebaseUid);

        if (optionalAdmin.isEmpty()) {
            return false;
        }

        AdminDetailsEntity admin = optionalAdmin.get();

        String role = admin.getRole();

        if (role == null) {
            return false;
        }

        return role.equalsIgnoreCase("ADMIN")
                || role.equalsIgnoreCase("SUPER_ADMIN");
    }

    private boolean isFilePathBelongsToOrder(
        Firestore db,
        Long orderId,
        Map<String, Object> orderData,
        String filePath
) throws Exception {
    String cleanFilePath = filePath.trim();

    if (cleanFilePath.isBlank()) {
        return false;
    }

    // 1. Main order document ke direct fields check
    if (cleanFilePath.equals(getString(orderData, "filePath"))) {
        return true;
    }

    if (cleanFilePath.equals(getString(orderData, "userFilePath"))) {
        return true;
    }

    if (cleanFilePath.equals(getString(orderData, "latestSubmissionFilePath"))) {
        return true;
    }

    if (cleanFilePath.equals(getString(orderData, "writerSubmissionFilePath"))) {
        return true;
    }

    if (cleanFilePath.equals(getString(orderData, "writerSubmissionVideoPath"))) {
        return true;
    }

    if (cleanFilePath.equals(getString(orderData, "videoPath"))) {
        return true;
    }

    // 2. Agar order document ke andar array stored hai to check
    if (checkSubmissionList(orderData.get("writerSubmission"), cleanFilePath)) {
        return true;
    }

    if (checkSubmissionList(orderData.get("writerSubmissions"), cleanFilePath)) {
        return true;
    }

    // 3. Important: writerSubmission subcollection check
    var submissionsSnapshot = db.collection("orders")
            .document(orderId.toString())
            .collection("writerSubmission")
            .get()
            .get();

    if (!submissionsSnapshot.isEmpty()) {
        for (QueryDocumentSnapshot document : submissionsSnapshot.getDocuments()) {
            Map<String, Object> submissionData = document.getData();

            if (submissionData == null) {
                continue;
            }

            if (cleanFilePath.equals(getString(submissionData, "filePath"))) {
                return true;
            }

            if (cleanFilePath.equals(getString(submissionData, "submissionFilePath"))) {
                return true;
            }

            if (cleanFilePath.equals(getString(submissionData, "writerSubmissionFilePath"))) {
                return true;
            }

            if (cleanFilePath.equals(getString(submissionData, "latestSubmissionFilePath"))) {
                return true;
            }

            if (cleanFilePath.equals(getString(submissionData, "videoPath"))) {
                return true;
            }

            if (cleanFilePath.equals(getString(submissionData, "submissionVideoPath"))) {
                return true;
            }

            if (cleanFilePath.equals(getString(submissionData, "writerSubmissionVideoPath"))) {
                return true;
            }
        }
    }

    // 4. Final safe fallback:
    // Admin ko sirf isi order folder ke andar ke files access karne do.
    // Example: orders/1/writer/uid/file.pdf
    String allowedOrderPrefix = "orders/" + orderId + "/";

    if (cleanFilePath.startsWith(allowedOrderPrefix)) {
        return true;
    }

    return false;
}
    private String getString(Map<String, Object> data, String key) {
        Object value = data.get(key);

        if (value == null) {
            return null;
        }

        return value.toString();
    }

    private String toStringValue(Object value) {
        if (value == null) {
            return null;
        }

        return value.toString();
    }


    private boolean checkSubmissionList(Object writerSubmissions, String cleanFilePath) {
    if (writerSubmissions instanceof List<?> submissionsList) {
        for (Object item : submissionsList) {
            if (item instanceof Map<?, ?> submissionMap) {
                Object path1 = submissionMap.get("filePath");
                Object path2 = submissionMap.get("submissionFilePath");
                Object path3 = submissionMap.get("writerSubmissionFilePath");
                Object path4 = submissionMap.get("latestSubmissionFilePath");
                Object path5 = submissionMap.get("videoPath");
                Object path6 = submissionMap.get("submissionVideoPath");
                Object path7 = submissionMap.get("writerSubmissionVideoPath");

                if (cleanFilePath.equals(toStringValue(path1))) return true;
                if (cleanFilePath.equals(toStringValue(path2))) return true;
                if (cleanFilePath.equals(toStringValue(path3))) return true;
                if (cleanFilePath.equals(toStringValue(path4))) return true;
                if (cleanFilePath.equals(toStringValue(path5))) return true;
                if (cleanFilePath.equals(toStringValue(path6))) return true;
                if (cleanFilePath.equals(toStringValue(path7))) return true;
            }
        }
    }

    return false;
}
}