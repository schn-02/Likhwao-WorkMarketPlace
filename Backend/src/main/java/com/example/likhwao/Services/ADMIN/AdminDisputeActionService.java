package com.example.likhwao.Services.ADMIN;


import com.example.likhwao.DTO.ADMIN.AdminDisputeReviseRequestDto;
import com.example.likhwao.Entity.ADMIN.AdminDetailsEntity;
import com.example.likhwao.Entity.ADMIN.AdminDisputeEntity;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Repository.ADMIN.AdminDetailsRepository;
import com.example.likhwao.Repository.ADMIN.AdminDisputeRepository;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.SetOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
public class AdminDisputeActionService {

    private final AdminDetailsRepository adminDetailsRepository;
    private final AdminDisputeRepository disputeRepository;
    private final UserOrdersDetailsEntityRepository userOrdersDetailsEntityRepository;

    private static final String DISPUTE_STATUS_REVISION_REQUESTED = "REVISION_REQUESTED";
    private static final String ORDER_STATUS_REVISION_REQUESTED = "REVISION_REQUESTED";
    private static final String ADMIN_ACTION_ASK_WRITER_TO_REVISE = "ASK_WRITER_TO_REVISE";

    public AdminDisputeActionService(
            AdminDetailsRepository adminDetailsRepository,
            AdminDisputeRepository disputeRepository,
            UserOrdersDetailsEntityRepository userOrdersDetailsEntityRepository
    ) {
        this.adminDetailsRepository = adminDetailsRepository;
        this.disputeRepository = disputeRepository;
        this.userOrdersDetailsEntityRepository = userOrdersDetailsEntityRepository;
    }

    @Transactional
    public Map<String, Object> changeStatusToRequestChanges(
            String token,
            Long disputesId,
            AdminDisputeReviseRequestDto request
    ) throws Exception {

        if (token == null || !token.startsWith("Bearer ")) {
            throw new RuntimeException("Unauthorized Admin");
        }

        if (disputesId == null) {
            throw new RuntimeException("Dispute id is required");
        }

        String idToken = token.substring(7);

        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String adminUid = decodedToken.getUid();

        AdminDetailsEntity admin = adminDetailsRepository
                .findByFirebaseUid(adminUid)
                .orElseThrow(() -> new RuntimeException("Admin not found"));

        if (!isValidAdmin(admin)) {
            throw new RuntimeException("Unauthorized Admin");
        }

        AdminDisputeEntity dispute = disputeRepository
                .findById(disputesId)
                .orElseThrow(() -> new RuntimeException("Dispute not found"));

        if (dispute.getOrderId() == null) {
            throw new RuntimeException("Order id not found in dispute");
        }

        String adminDecisionNote = getAdminDecisionNote(request);

        LocalDateTime nowLocal = LocalDateTime.now();
        Timestamp nowTimestamp = Timestamp.now();

        dispute.setDisputeStatus(DISPUTE_STATUS_REVISION_REQUESTED);
        dispute.setAdminDecisionNote(adminDecisionNote);
        dispute.setAdminFirebaseUid(admin.getFirebaseUid());
        dispute.setUpdatedAt(nowLocal);

        disputeRepository.save(dispute);

        UserOrdersDetailsEntity order = userOrdersDetailsEntityRepository
                .findById(dispute.getOrderId())
                .orElseThrow(() -> new RuntimeException("Order not found"));

        order.setOrderStatus(ORDER_STATUS_REVISION_REQUESTED);
        order.setWriterAssignmentStatus(ORDER_STATUS_REVISION_REQUESTED);

        userOrdersDetailsEntityRepository.save(order);

        updateFirestoreAfterAskRevision(
                dispute,
                admin,
                adminDecisionNote,
                nowTimestamp
        );

        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "Revision requested from writer successfully");
        response.put("disputeId", dispute.getId());
        response.put("orderId", dispute.getOrderId());
        response.put("disputeStatus", DISPUTE_STATUS_REVISION_REQUESTED);
        response.put("orderStatus", ORDER_STATUS_REVISION_REQUESTED);

        return response;
    }

    private boolean isValidAdmin(AdminDetailsEntity admin) {
        if (admin == null) {
            return false;
        }

        if (admin.getFirebaseUid() == null || admin.getFirebaseUid().isBlank()) {
            return false;
        }

        String role = admin.getRole();

        if (role == null || role.isBlank()) {
            return true;
        }

        return role.equalsIgnoreCase("ADMIN")
                || role.equalsIgnoreCase("SUPER_ADMIN");
    }

    private String getAdminDecisionNote(AdminDisputeReviseRequestDto request) {
        if (request == null ||
                request.getAdminDecisionNote() == null ||
                request.getAdminDecisionNote().trim().isEmpty()) {
            return "Admin requested writer to revise the submitted work.";
        }

        return request.getAdminDecisionNote().trim();
    }

    private void updateFirestoreAfterAskRevision(
            AdminDisputeEntity dispute,
            AdminDetailsEntity admin,
            String adminDecisionNote,
            Timestamp nowTimestamp
    ) throws Exception {

        Firestore db = FirestoreClient.getFirestore();

        Long orderId = dispute.getOrderId();
        Long disputeId = dispute.getId();
        
        updateMainOrderDocument(
                db,
                orderId,
                admin,
                adminDecisionNote,
                nowTimestamp
        );

        updateDisputeDocument(
                db,
                orderId,
                disputeId,
                admin,
                adminDecisionNote,
                nowTimestamp
        );

        updateLatestWriterSubmissionDocument(
                db,
                orderId,
                admin,
                adminDecisionNote,
                nowTimestamp
        );
    }

    private void updateMainOrderDocument(
            Firestore db,
            Long orderId,
            AdminDetailsEntity admin,
            String adminDecisionNote,
            Timestamp nowTimestamp
    ) throws Exception {

        Map<String, Object> orderUpdateMap = new HashMap<>();

        orderUpdateMap.put("status", ORDER_STATUS_REVISION_REQUESTED);
        orderUpdateMap.put("orderStatus", ORDER_STATUS_REVISION_REQUESTED);
        orderUpdateMap.put("writerAssignmentStatus", ORDER_STATUS_REVISION_REQUESTED);

        orderUpdateMap.put("statusLabel", "Admin Requested Writer Revision");

        orderUpdateMap.put("latestSubmissionStatus", DISPUTE_STATUS_REVISION_REQUESTED);
        orderUpdateMap.put("hasWriterSubmission", true);

        orderUpdateMap.put("adminRevisionRequested", true);
        orderUpdateMap.put("adminRevisionRequestedAtTimestamp", nowTimestamp);
        orderUpdateMap.put("adminRevisionNote", adminDecisionNote);
        orderUpdateMap.put("adminFirebaseUid", admin.getFirebaseUid());

        orderUpdateMap.put("writerCanUploadRevision", true);
        orderUpdateMap.put("userCanAcceptWork", false);
        orderUpdateMap.put("userCanRequestChanges", false);

        orderUpdateMap.put("updatedAtTimestamp", nowTimestamp);

        db.collection("orders")
                .document(orderId.toString())
                .set(orderUpdateMap, SetOptions.merge())
                .get();
    }

    private void updateDisputeDocument(
            Firestore db,
            Long orderId,
            Long disputeId,
            AdminDetailsEntity admin,
            String adminDecisionNote,
            Timestamp nowTimestamp
    ) throws Exception {

        Map<String, Object> disputeUpdateMap = new HashMap<>();

        disputeUpdateMap.put("disputeStatus", DISPUTE_STATUS_REVISION_REQUESTED);
        disputeUpdateMap.put("orderStatus", ORDER_STATUS_REVISION_REQUESTED);
        disputeUpdateMap.put("statusLabel", "Revision Requested From Writer");

        disputeUpdateMap.put("adminAction", ADMIN_ACTION_ASK_WRITER_TO_REVISE);
        disputeUpdateMap.put("adminDecisionNote", adminDecisionNote);
        disputeUpdateMap.put("adminFirebaseUid", admin.getFirebaseUid());

        disputeUpdateMap.put("writerActionRequired", true);
        disputeUpdateMap.put("userActionRequired", false);

        disputeUpdateMap.put("readByWriter", false);
        disputeUpdateMap.put("readByUser", false);
        disputeUpdateMap.put("readByAdmin", true);

        disputeUpdateMap.put("revisionRequestedAtTimestamp", nowTimestamp);
        disputeUpdateMap.put("updatedAtTimestamp", nowTimestamp);

        QuerySnapshot disputeSnapshot = db.collection("orders")
                .document(orderId.toString())
                .collection("disputes")
                .whereEqualTo("disputeId", disputeId)
                .get()
                .get();

        if (!disputeSnapshot.isEmpty()) {
            for (QueryDocumentSnapshot document : disputeSnapshot.getDocuments()) {
                document.getReference()
                        .set(disputeUpdateMap, SetOptions.merge())
                        .get();
            }
            return;
        }

        db.collection("orders")
                .document(orderId.toString())
                .collection("disputes")
                .document(disputeId.toString())
                .set(disputeUpdateMap, SetOptions.merge())
                .get();
    }

    private void updateLatestWriterSubmissionDocument(
            Firestore db,
            Long orderId,
            AdminDetailsEntity admin,
            String adminDecisionNote,
            Timestamp nowTimestamp
    ) throws Exception {

        ApiFuture<QuerySnapshot> future = db.collection("orders")
                .document(orderId.toString())
                .collection("writerSubmission")
                .whereEqualTo("isLatest", true)
                .get();

        QuerySnapshot snapshot = future.get();

        if (snapshot.isEmpty()) {
            return;
        }

        Map<String, Object> submissionUpdateMap = new HashMap<>();

        submissionUpdateMap.put("status", DISPUTE_STATUS_REVISION_REQUESTED);
        submissionUpdateMap.put("submissionStatus", DISPUTE_STATUS_REVISION_REQUESTED);

        submissionUpdateMap.put("adminRevisionRequested", true);
        submissionUpdateMap.put("adminRevisionNote", adminDecisionNote);
        submissionUpdateMap.put("adminFirebaseUid", admin.getFirebaseUid());
        submissionUpdateMap.put("adminRevisionRequestedAtTimestamp", nowTimestamp);

        submissionUpdateMap.put("writerCanUploadRevision", true);
        submissionUpdateMap.put("updatedAtTimestamp", nowTimestamp);

        for (QueryDocumentSnapshot document : snapshot.getDocuments()) {
            document.getReference()
                    .set(submissionUpdateMap, SetOptions.merge())
                    .get();
        }
    }
}