package com.example.likhwao.Services.ADMIN;


import com.example.likhwao.DTO.ADMIN.AdminRaiseDisputeRequestDto;
import com.example.likhwao.DTO.ADMIN.AdminRaiseDisputeResponse;
import com.example.likhwao.Entity.ADMIN.AdminDisputeEntity;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Repository.ADMIN.AdminDisputeRepository;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class AdminUserDisputeService {

    private final AdminDisputeRepository disputeRepository;
    private final UserOrdersDetailsEntityRepository userOrdersDetailsEntityRepository;

    public AdminUserDisputeService(
            AdminDisputeRepository disputeRepository,
            UserOrdersDetailsEntityRepository userOrdersDetailsEntityRepository
    ) {
        this.disputeRepository = disputeRepository;
        this.userOrdersDetailsEntityRepository = userOrdersDetailsEntityRepository;
    }

    @Transactional(rollbackFor = Exception.class)
    public AdminRaiseDisputeResponse raiseDispute(
            Long orderId,
            String token,
            AdminRaiseDisputeRequestDto request
    ) throws Exception {

if (token == null || !token.startsWith("Bearer ")) {
    throw new RuntimeException("Unauthorized user");
}

String idToken = token.substring(7);

if (idToken.trim().isEmpty()) {
    throw new RuntimeException("Unauthorized user");
}

FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);

String userFirebaseUid = decodedToken.getUid();
        if (userFirebaseUid == null || userFirebaseUid.trim().isEmpty()) {
            throw new RuntimeException("Unauthorized user");
        }

        if (request.getReason() == null || request.getReason().trim().isEmpty()) {
            throw new RuntimeException("Dispute reason is required");
        }

        if (request.getMessage() == null || request.getMessage().trim().isEmpty()) {
            throw new RuntimeException("Dispute message is required");
        }

        String reason = request.getReason().trim();
        String message = request.getMessage().trim();

        if (message.length() > 2000) {
            throw new RuntimeException("Dispute message is too long");
        }

        UserOrdersDetailsEntity order = userOrdersDetailsEntityRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        if (order.getUserFirebaseUid() == null ||
                !order.getUserFirebaseUid().equals(userFirebaseUid)) {
            throw new RuntimeException("You are not allowed to raise dispute for this order");
        }

        if (order.getWriterAssignmentStatus() == null ||
                !order.getWriterAssignmentStatus().equalsIgnoreCase("REVIEW")) {
            throw new RuntimeException("Dispute can be raised only after writer submits work");
        }

        if (order.getWriterFirebaseUid() == null ||
                order.getWriterFirebaseUid().trim().isEmpty()) {
            throw new RuntimeException("Writer not found for this order");
        }

        List<String> activeDisputeStatuses = Arrays.asList(
                "OPEN",
                "ADMIN_REVIEWING",
                "WAITING_USER_REPLY",
                "WAITING_WRITER_REPLY",
                "REVISION_REQUESTED"
        );

        boolean alreadyActiveDispute = disputeRepository.existsByOrderIdAndDisputeStatusIn(
                orderId,
                activeDisputeStatuses
        );

        if (alreadyActiveDispute) {
            throw new RuntimeException("An active dispute already exists for this order");
        }

        Firestore firestore = FirestoreClient.getFirestore();

        String latestWriterSubmissionVersion = getLatestWriterSubmissionVersion(
                firestore,
                orderId
        );

        if (latestWriterSubmissionVersion == null) {
            throw new RuntimeException("Writer submission not found");
        }

        LocalDateTime now = LocalDateTime.now();

       AdminDisputeEntity dispute = new AdminDisputeEntity();
        dispute.setOrderId(order.getId());
        dispute.setUserFirebaseUid(order.getUserFirebaseUid());
        dispute.setWriterFirebaseUid(order.getWriterFirebaseUid());
        dispute.setReason(reason);
        dispute.setMessage(message);
        dispute.setDisputeStatus("OPEN");
        dispute.setOrderStatusAtDispute(order.getOrderStatus());
        dispute.setWriterSubmissionVersion(latestWriterSubmissionVersion);
        dispute.setCreatedAt(now);
        dispute.setUpdatedAt(now);
        dispute.setRaisedBy("USER");
        dispute.setRaisedByFirebaseUid(order.getUser().getFirebaseUid());


        AdminDisputeEntity savedDispute = disputeRepository.saveAndFlush(dispute);

        order.setOrderStatus("DISPUTED");
        userOrdersDetailsEntityRepository.save(order);

        saveDisputeInFirestore(
                firestore,
                savedDispute,
                order,
                latestWriterSubmissionVersion
        );

        updateOrderDisputeStatusInFirestore(
                firestore,
                order.getId(),
                savedDispute.getId()
        );

        return new AdminRaiseDisputeResponse(
                "success",
                "Dispute raised successfully",
                savedDispute.getId(),
                order.getId(),
                "OPEN",
                "DISPUTED",
                latestWriterSubmissionVersion
        );
    }

    private String getLatestWriterSubmissionVersion(
            Firestore firestore,
            Long orderId
    ) throws Exception {

        CollectionReference writerSubmissionRef = firestore
                .collection("orders")
                .document(String.valueOf(orderId))
                .collection("writerSubmission");

        QuerySnapshot snapshot = writerSubmissionRef.get().get();

        String latestVersion = null;
        int maxVersionNumber = -1;

        for (QueryDocumentSnapshot document : snapshot.getDocuments()) {
            String documentId = document.getId();

            if (documentId != null && documentId.matches("v\\d+")) {
                int versionNumber = Integer.parseInt(documentId.substring(1));

                if (versionNumber > maxVersionNumber) {
                    maxVersionNumber = versionNumber;
                    latestVersion = documentId;
                }
            }
        }

        return latestVersion;
    }

    private void saveDisputeInFirestore(
            Firestore firestore,
            AdminDisputeEntity dispute,
            UserOrdersDetailsEntity order,
            String latestWriterSubmissionVersion
    ) throws Exception {

        Map<String, Object> disputeData = new HashMap<>();

        disputeData.put("disputeId", dispute.getId());
        disputeData.put("orderId", dispute.getOrderId());

        disputeData.put("userFirebaseUid", dispute.getUserFirebaseUid());
        disputeData.put("writerFirebaseUid", dispute.getWriterFirebaseUid());

        disputeData.put("userName", order.getUserName());
        disputeData.put("userNumber", order.getUserNumber());

        disputeData.put("fileName", order.getFileName());
        disputeData.put("filePageCount", order.getFilePageCount());
        disputeData.put("totalOrderAmount", order.getTotalOrderAmount());

        disputeData.put("reason", dispute.getReason());
        disputeData.put("messagePreview", createMessagePreview(dispute.getMessage()));

        disputeData.put("disputeStatus", "OPEN");
        disputeData.put("orderStatus", "DISPUTED");
        disputeData.put("statusLabel", "Admin Reviewing Dispute");

        disputeData.put("writerSubmissionVersion", latestWriterSubmissionVersion);

        disputeData.put("readByAdmin", false);
        disputeData.put("createdAtTimestamp", Timestamp.now());
        disputeData.put("updatedAtTimestamp", Timestamp.now());

        firestore.collection("disputes")
                .document(String.valueOf(dispute.getId()))
                .set(disputeData, SetOptions.merge())
                .get();
    }

    private void updateOrderDisputeStatusInFirestore(
            Firestore firestore,
            Long orderId,
            Long disputeId
    ) throws Exception {

        Map<String, Object> orderUpdate = new HashMap<>();

        orderUpdate.put("status", "DISPUTED");
        orderUpdate.put("orderStatus", "DISPUTED");
        orderUpdate.put("statusLabel", "Admin Reviewing Dispute");
        orderUpdate.put("hasDispute", true);
        orderUpdate.put("activeDisputeId", disputeId);
        orderUpdate.put("statusUpdatedAtTimestamp", Timestamp.now());

        firestore.collection("orders")
                .document(String.valueOf(orderId))
                .set(orderUpdate, SetOptions.merge())
                .get();
    }

    private String createMessagePreview(String message) {
        if (message == null) {
            return "";
        }

        if (message.length() <= 80) {
            return message;
        }

        return message.substring(0, 80) + "...";
    }
}