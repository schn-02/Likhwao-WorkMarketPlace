package com.example.likhwao.Services.WRITER;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.example.likhwao.Entity.USER.UserDetailsEntity;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Entity.WRITER.OrderWriterActionEntity;
import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;
import com.example.likhwao.Entity.WRITER.WriterWorkEntity;
import com.example.likhwao.Model.WriterWorkModel;
import com.example.likhwao.Repository.USER.UserDetailsEntityRepository;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.example.likhwao.Repository.WRITER.OrderWriterActionEntityRepository;
import com.example.likhwao.Repository.WRITER.WriterWorkRepository;
import com.example.likhwao.Repository.WRITER.WritersDetailsEntityRepository;
import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.WriteBatch;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Bucket;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;
import com.google.firebase.cloud.StorageClient;

import jakarta.transaction.Transactional;

@Service
public class WriterWorkService {

    @Autowired
    private WriterWorkRepository wwr;

    @Autowired
    private UserOrdersDetailsEntityRepository uDetailsEntityRepository;

    @Autowired
    private OrderWriterActionEntityRepository orderWriterActionEntityRepository;

    @Autowired
    private WritersDetailsEntityRepository wder;

    @Autowired
    private UserDetailsEntityRepository uder;

    @Transactional
    public ResponseEntity<Map<String, Object>> saveWriterWork(String token, WriterWorkModel wwm) {

        WriterWorkEntity wEntity = new WriterWorkEntity();

        WriterDetailsEntity writer = wder.findById(wwm.getWriterId())
                .orElseThrow(() -> new RuntimeException("Writer not found"));

        UserOrdersDetailsEntity order = uDetailsEntityRepository.findById(wwm.getUserOrderId())
                .orElseThrow(() -> new RuntimeException("Order not found"));

        UserDetailsEntity user = uder.findById(wwm.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

                

        wEntity.setUserOrder(order);
        wEntity.setFileName(wwm.getFileName());
        wEntity.setFilePageCount(wwm.getFilePageCount());
        wEntity.setFileSize(wwm.getFileSize());
        wEntity.setFilePath(wwm.getFileUrl());
        wEntity.setOrderCreatedAt(wwm.getOrderCreatedAt());
        wEntity.setWriterAssignmentStatus(wwm.getWriterAssignmentStatus());
        wEntity.setWriter(writer);
        wEntity.setWriterSuggestionText(wwm.getWriterSuggestionText());
        wEntity.setUser(user);
        wEntity.setOrderCompletedAt_REVIEW(wwm.getOrderCompletedAt());

        order.setWriterAssignmentStatus(wwm.getWriterAssignmentStatus());

        OrderWriterActionEntity orderWriterActionEntity =
                orderWriterActionEntityRepository
                        .findByWriterAndOrder(writer, order)
                        .orElseThrow(() -> new RuntimeException("Order Action Table not Found"));

        orderWriterActionEntity.setAction(wwm.getWriterAssignmentStatus());

        uDetailsEntityRepository.save(order);
        orderWriterActionEntityRepository.save(orderWriterActionEntity);

   
        WriterWorkEntity savedWriterWork = wwr.save(wEntity);

        int version = saveIntoFirebase(order, wwm, savedWriterWork);

        Map<String, Object> response = new HashMap<>();
        response.put("orderId", order.getId());
        response.put("status", order.getWriterAssignmentStatus());
        response.put("submissionVersion", version);
        response.put("writerWorkId", savedWriterWork.getWriterWorkId());
        response.put("fileName", wwm.getFileName());
        response.put("filePath", wwm.getFileUrl());

        return ResponseEntity.ok(response);
    }

    public int saveIntoFirebase(
            UserOrdersDetailsEntity orders,
            WriterWorkModel wwm,
            WriterWorkEntity savedWriterWork
    ) {
        try {

            Firestore db = FirestoreClient.getFirestore();

            String orderId = orders.getId().toString();

            int version = getNextSubmissionVersion(db, orderId);

            markOldLatestSubmissionFalse(db, orderId);

            String uploadedAt = wwm.getOrderCompletedAt() != null
                    ? wwm.getOrderCompletedAt().toString()
                    : LocalDateTime.now().toString();

            String submissionStatus = "ON_REVIEW";

            Map<String, Object> updatedMap = new HashMap<>();

            Timestamp nowTimestamp = Timestamp.now();

updatedMap.put("latestSubmissionUploadedAtTimestamp", nowTimestamp);



            updatedMap.put("status", orders.getWriterAssignmentStatus());
            updatedMap.put("hasWriterSubmission", true);

            updatedMap.put("latestSubmissionVersion", version);


            updatedMap.put("latestWriterWorkId", savedWriterWork.getWriterWorkId());

            updatedMap.put("latestSubmissionStatus", submissionStatus);
            updatedMap.put("latestSubmissionFileName", wwm.getFileName());
            updatedMap.put("latestSubmissionFilePath", wwm.getFileUrl());
            updatedMap.put("latestSubmissionFileSize", wwm.getFileSize());
            updatedMap.put("latestSubmissionPageCount", wwm.getFilePageCount());
            updatedMap.put("latestSubmissionUploadedAt", uploadedAt);
            updatedMap.put("latestSubmissionWriterNote", wwm.getWriterSuggestionText());

            updatedMap.put("writerId", orders.getWriter().getId());
            updatedMap.put("writerName", orders.getWriter().getName());
            updatedMap.put("writerFirebaseUid", orders.getWriterFirebaseUid());

            updatedMap.put("hasWriter", true);
updatedMap.put("hasWriterSubmission", true);
updatedMap.put("updatedAtTimestamp", Timestamp.now());
updatedMap.put("statusUpdatedAtTimestamp", Timestamp.now());

            db.collection("orders")
                    .document(orderId)
                    .update(updatedMap);

            Map<String, Object> map = new HashMap<>();

            map.put("orderId", orders.getId());

            map.put("writerWorkId", savedWriterWork.getWriterWorkId());

            map.put("version", version);
            map.put("isLatest", true);

            map.put("status", orders.getWriterAssignmentStatus());
            map.put("submissionStatus", submissionStatus);

            map.put("fileName", wwm.getFileName());
            map.put("filePath", wwm.getFileUrl());
            map.put("fileSize", wwm.getFileSize());
            map.put("filePageCount", wwm.getFilePageCount());
            map.put("fileType", getFileType(wwm.getFileName()));

            map.put("writerNote", wwm.getWriterSuggestionText());
           map.put("uploadedAt", uploadedAt);
map.put("uploadedAtTimestamp", nowTimestamp);

            map.put("changeRequestText", null);
            map.put("changeRequestedAt", null);
            map.put("acceptedAt", null);

            map.put("writerId", orders.getWriter().getId());
            map.put("writerName", orders.getWriter().getName());
            map.put("writerFirebaseUid", orders.getWriterFirebaseUid());

            map.put("userId", orders.getUser().getId());
            map.put("userFirebaseUid", orders.getUserFirebaseUid());

            map.put("totalOrderAmount", orders.getTotalOrderAmount());

            map.put(
                    "deadline",
                    orders.getSelectedDate() != null
                            ? orders.getSelectedDate().toString()
                            : null
            );

            db.collection("orders")
                    .document(orderId)
                    .collection("writerSubmission")
                    .document("v" + version)
                    .set(map);

            return version;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Writer submission firebase save failed");
        }
    }

    private int getNextSubmissionVersion(Firestore db, String orderId) {
        try {
            ApiFuture<QuerySnapshot> future = db.collection("orders")
                    .document(orderId)
                    .collection("writerSubmission")
                    .get();

            QuerySnapshot querySnapshot = future.get();

            return querySnapshot.size() + 1;

        } catch (Exception e) {
            e.printStackTrace();
            return 1;
        }
    }

    private void markOldLatestSubmissionFalse(Firestore db, String orderId) {
        try {
            ApiFuture<QuerySnapshot> future = db.collection("orders")
                    .document(orderId)
                    .collection("writerSubmission")
                    .whereEqualTo("isLatest", true)
                    .get();

            QuerySnapshot querySnapshot = future.get();

            if (querySnapshot.isEmpty()) {
                return;
            }

            WriteBatch batch = db.batch();

            for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
                DocumentReference ref = document.getReference();
                batch.update(ref, "isLatest", false);
            }

            batch.commit().get();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String getFileType(String fileName) {
        if (fileName == null) {
            return "FILE";
        }

        String lowerFileName = fileName.toLowerCase();

        if (lowerFileName.endsWith(".pdf")) {
            return "PDF";
        } else if (lowerFileName.endsWith(".jpg") ||
                lowerFileName.endsWith(".jpeg") ||
                lowerFileName.endsWith(".png")) {
            return "IMAGE";
        } else if (lowerFileName.endsWith(".mp4") ||
                lowerFileName.endsWith(".mov")) {
            return "VIDEO";
        }

        return "FILE";
    }

    public Map<String, String> uploadWriterFile(
            MultipartFile file,
            Long orderId,
            String token
    ) {
        try {

            if (token == null || !token.startsWith("Bearer ")) {
                throw new RuntimeException("Token is missing");
            }

            token = token.substring(7);

            FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
            String writerUid = decoded.getUid();

            String originalFileName = file.getOriginalFilename();

            if (originalFileName == null || originalFileName.isBlank()) {
                originalFileName = "writer_work";
            }

            String safeFileName = originalFileName.replaceAll("\\s+", "_");

            String filePath = "orders/" + orderId + "/writer/" + writerUid + "/"
                    + System.currentTimeMillis() + "_" + safeFileName;

            Bucket bucket = StorageClient.getInstance()
                    .bucket("likhwao-15dcc.firebasestorage.app");

            BlobInfo blobInfo = BlobInfo.newBuilder(bucket.getName(), filePath)
                    .setContentType(file.getContentType())
                    .build();

            bucket.getStorage().create(blobInfo, file.getBytes());

            Map<String, String> response = new HashMap<>();
            response.put("filePath", filePath);
            response.put("fileName", originalFileName);
            response.put("contentType", file.getContentType());
            response.put("fileSize", String.valueOf(file.getSize()));

            return response;

        } catch (Exception e) {
            throw new RuntimeException("Writer file upload failed: " + e.getMessage());
        }
    }
}