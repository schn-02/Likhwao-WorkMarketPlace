package com.example.likhwao.Services.ADMIN;

import com.example.likhwao.DTO.ADMIN.AdminDisputeOrderDetailsResponseDto;
import com.example.likhwao.Entity.ADMIN.AdminDetailsEntity;
import com.example.likhwao.Entity.ADMIN.AdminDisputeEntity;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Repository.ADMIN.AdminDetailsRepository;
import com.example.likhwao.Repository.ADMIN.AdminDisputeRepository;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class AdminDisputeOrderDetailsService {

    private final AdminDisputeRepository disputeRepository;
    private final UserOrdersDetailsEntityRepository orderRepository;

    @Autowired
    private  AdminDetailsRepository adminDetailsRepository;

    public AdminDisputeOrderDetailsService(
            AdminDisputeRepository disputeRepository,
            UserOrdersDetailsEntityRepository orderRepository
    ) {
        this.disputeRepository = disputeRepository;
        this.orderRepository = orderRepository;
    }

    @Transactional(readOnly = true)
    public AdminDisputeOrderDetailsResponseDto getDisputeOrderDetails(
            Long disputeId,
            String authorizationHeader
    ) throws Exception {

        verifyAdminToken(authorizationHeader);

        AdminDisputeEntity dispute = disputeRepository.findById(disputeId)
                .orElseThrow(() -> new RuntimeException("Dispute not found"));

        UserOrdersDetailsEntity order = orderRepository.findById(dispute.getOrderId())
                .orElseThrow(() -> new RuntimeException("Order not found for this dispute"));

        Firestore firestore = FirestoreClient.getFirestore();

        Map<String, Object> disputeFsData = getDocumentData(
                firestore.collection("disputes").document(disputeId.toString())
        );

        Map<String, Object> orderFsData = getDocumentData(
                firestore.collection("orders").document(order.getId().toString())
        );

        String submissionVersion = firstNonBlank(
                dispute.getWriterSubmissionVersion(),
                disputeFsData.get("writerSubmissionVersion"),
                orderFsData.get("latestWriterSubmissionVersion"),
                orderFsData.get("writerSubmissionVersion")
        );

        Map<String, Object> submissionData = getWriterSubmissionData(
                firestore,
                order.getId(),
                submissionVersion
        );

        AdminDisputeOrderDetailsResponseDto response =
                new AdminDisputeOrderDetailsResponseDto("success", "Dispute order details fetched successfully");

        response.disputeId = dispute.getId();
        response.orderId = order.getId();

        response.disputeStatus = firstNonBlank(dispute.getDisputeStatus(), disputeFsData.get("disputeStatus"));
        response.disputeReason = firstNonBlank(dispute.getReason(), disputeFsData.get("reason"));
        response.disputeMessage = firstNonBlank(dispute.getMessage(), disputeFsData.get("message"), disputeFsData.get("messagePreview"));
        response.orderStatusAtDispute = firstNonBlank(dispute.getOrderStatusAtDispute(), disputeFsData.get("orderStatusAtDispute"));
        response.writerSubmissionVersion = firstNonBlank(submissionVersion, submissionData.get("documentId"));
        response.disputeCreatedAt = toText(firstNonBlank(dispute.getCreatedAt(), disputeFsData.get("createdAtTimestamp")));
        response.disputeUpdatedAt = toText(firstNonBlank(dispute.getUpdatedAt(), disputeFsData.get("updatedAtTimestamp")));

        response.orderStatus = firstNonBlank(order.getOrderStatus(), orderFsData.get("orderStatus"), orderFsData.get("status"));
        response.writerAssignmentStatus = firstNonBlank(order.getWriterAssignmentStatus(), orderFsData.get("writerAssignmentStatus"));
        response.statusLabel = firstNonBlank(orderFsData.get("statusLabel"));

        response.userFirebaseUid = firstNonBlank(order.getUserFirebaseUid(), dispute.getUserFirebaseUid(), disputeFsData.get("userFirebaseUid"));
        response.userName = firstNonBlank(order.getUserName(), orderFsData.get("userName"), disputeFsData.get("userName"));
        response.userNumber = firstNonBlank(order.getUserNumber(), orderFsData.get("userNumber"), disputeFsData.get("userNumber"));

        response.writerFirebaseUid = firstNonBlank(order.getWriterFirebaseUid(), dispute.getWriterFirebaseUid(), disputeFsData.get("writerFirebaseUid"));
        response.writerName = firstNonBlank(orderFsData.get("writerName"), disputeFsData.get("writerName"), "Writer Assigned");

        response.fileName = firstNonBlank(order.getFileName(), orderFsData.get("fileName"));
        response.userFilePath = firstNonBlank(order.getUserFilePath(), orderFsData.get("userFilePath"));
        response.fileSize = order.getFileSize();
        response.filePageCount = firstInteger(order.getFilePageCount(), orderFsData.get("filePageCount"));

        response.writerSubmissionFileName = firstNonBlank(
                submissionData.get("fileName"),
                submissionData.get("writerFileName"),
                submissionData.get("submissionFileName")
        );

        response.writerSubmissionFileUrl = firstNonBlank(
                submissionData.get("fileUrl"),
                submissionData.get("writerFileUrl"),
                submissionData.get("submissionFileUrl"),
                submissionData.get("downloadUrl"),
                submissionData.get("uploadedFileUrl")
        );

        response.writerSubmissionFilePath = firstNonBlank(
                submissionData.get("filePath"),
                submissionData.get("writerFilePath"),
                submissionData.get("submissionFilePath")
        );

        response.writerSubmissionVideoUrl = firstNonBlank(
                submissionData.get("videoUrl"),
                submissionData.get("writerVideoUrl"),
                submissionData.get("submissionVideoUrl")
        );

        response.writerSubmissionText = firstNonBlank(
                submissionData.get("text"),
                submissionData.get("message"),
                submissionData.get("description"),
                submissionData.get("writerNote")
        );

        response.writerSubmittedAt = toText(firstNonBlank(
                submissionData.get("createdAtTimestamp"),
                submissionData.get("uploadedAtTimestamp"),
                submissionData.get("submittedAtTimestamp")
        ));

        response.typeOfWork = firstNonBlank(order.getTypeOfWork(), orderFsData.get("typeOfWork"));
        response.selectedLanguage = firstNonBlank(order.getLanguageSelectedChips(), orderFsData.get("selectedLanguage"));
        response.selectedInkColor = firstNonBlank(order.getSelectedInkColor(), orderFsData.get("selectedInkColor"), orderFsData.get("InkColor"));
        response.selectedNotebook = firstNonBlank(order.getSelectedNotebook(), orderFsData.get("selectedNotebook"), orderFsData.get("NotebookType"));
        response.writerSuggestionText = firstNonBlank(order.getWriterSuggestionText(), orderFsData.get("writerSuggestionText"));
        response.workToBeDone = firstNonBlank(order.getWorkToBeDone(), orderFsData.get("workToBeDone"));

        response.deliveryPickupOption = firstNonBlank(order.getDeliveryPickupOption(), orderFsData.get("deliveryPickupOption"));
        response.deliveryAddress = firstNonBlank(order.getDeliveryAddress(), orderFsData.get("deliveryAddress"));
        response.latitude = order.getLatitude();
        response.longitude = order.getLongitude();

        response.urgency = firstNonBlank(order.getSelectedDeadLineUrgency(), orderFsData.get("urgency"), orderFsData.get("selectedDeadLineUrgency"));
        response.deadline = firstNonBlank(
                order.getSelectedDate() == null ? null : order.getSelectedDate().toString(),
                orderFsData.get("deadline"),
                orderFsData.get("selectedDate")
        );

        response.orderPageCountAmount = firstInteger(order.getOrderPageCountAmount(), orderFsData.get("orderPageCountAmount"));
        response.urgencyAmount = firstInteger(order.getUrgencyAmount(), orderFsData.get("urgencyAmount"));
        response.deliveryChargesAmount = firstInteger(order.getDeliveryChargesAmount(), orderFsData.get("deliveryChargesAmount"));
        response.platformFeeAmount = firstInteger(order.getPlatformFeeAmount(), orderFsData.get("platformFeeAmount"));
        response.noteBookChargesAmount = firstInteger(order.getNoteBookChargesAmount(), orderFsData.get("noteBookChargesAmount"));
        response.totalOrderAmount = firstInteger(order.getTotalOrderAmount(), orderFsData.get("totalOrderAmount"));

        response.paymentStatus = firstNonBlank(order.getPaymentStatus(), orderFsData.get("paymentStatus"));
        response.paymentMethod = firstNonBlank(order.getPaymentMethod(), orderFsData.get("paymentMethod"));
        response.paymentBank = firstNonBlank(order.getPaymentBank(), orderFsData.get("paymentBank"));

        response.orderCreatedAt = order.getOrderCreatedAt() == null ? null : order.getOrderCreatedAt().toString();
        response.orderCompletedAt = order.getOrderCompletedAt() == null ? null : order.getOrderCompletedAt().toString();

        return response;
    }

    private void verifyAdminToken(String authorizationHeader) throws Exception {
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            throw new RuntimeException("Unauthorized admin");
        }

        String idToken = authorizationHeader.substring(7).trim();

        if (idToken.isEmpty()) {
            throw new RuntimeException("Unauthorized admin");
        }

        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);

        if (decodedToken.getUid() == null || decodedToken.getUid().trim().isEmpty()) {
            throw new RuntimeException("Unauthorized admin");
        }
    }

    private Map<String, Object> getDocumentData(DocumentReference documentReference) {
        try {
            DocumentSnapshot snapshot = documentReference.get().get();

            if (!snapshot.exists() || snapshot.getData() == null) {
                return new HashMap<>();
            }

            return new HashMap<>(snapshot.getData());
        } catch (Exception e) {
            return new HashMap<>();
        }
    }

    private Map<String, Object> getWriterSubmissionData(
            Firestore firestore,
            Long orderId,
            String version
    ) {
        try {
            if (version != null && !version.trim().isEmpty()) {
                Map<String, Object> versionData = getDocumentData(
                        firestore.collection("orders")
                                .document(orderId.toString())
                                .collection("writerSubmission")
                                .document(version)
                );

                if (!versionData.isEmpty()) {
                    versionData.put("documentId", version);
                    return versionData;
                }
            }

            QuerySnapshot snapshot = firestore.collection("orders")
                    .document(orderId.toString())
                    .collection("writerSubmission")
                    .get()
                    .get();

            List<QueryDocumentSnapshot> docs = snapshot.getDocuments();

            if (docs == null || docs.isEmpty()) {
                return new HashMap<>();
            }

            QueryDocumentSnapshot latestDoc = docs.get(0);
            int latestVersionNumber = parseVersionNumber(latestDoc.getId());

            for (QueryDocumentSnapshot doc : docs) {
                int currentVersionNumber = parseVersionNumber(doc.getId());

                if (currentVersionNumber > latestVersionNumber) {
                    latestVersionNumber = currentVersionNumber;
                    latestDoc = doc;
                }
            }

            Map<String, Object> latestData = new HashMap<>(latestDoc.getData());
            latestData.put("documentId", latestDoc.getId());

            return latestData;

        } catch (Exception e) {
            return new HashMap<>();
        }
    }

    private int parseVersionNumber(String documentId) {
        try {
            if (documentId == null) {
                return 0;
            }

            String clean = documentId.toLowerCase().replace("v", "").trim();

            return Integer.parseInt(clean);
        } catch (Exception e) {
            return 0;
        }
    }

    private String firstNonBlank(Object... values) {
        if (values == null) {
            return null;
        }

        for (Object value : values) {
            if (value == null) {
                continue;
            }

            String text = value.toString();

            if (!text.trim().isEmpty() && !text.equalsIgnoreCase("null")) {
                return text;
            }
        }

        return null;
    }

    private Integer firstInteger(Object... values) {
        if (values == null) {
            return null;
        }

        for (Object value : values) {
            if (value == null) {
                continue;
            }

            if (value instanceof Integer) {
                return (Integer) value;
            }

            if (value instanceof Long) {
                return ((Long) value).intValue();
            }

            try {
                return Integer.parseInt(value.toString());
            } catch (Exception ignored) {
            }
        }

        return null;
    }

    private String toText(Object value) {
        if (value == null) {
            return null;
        }

        return value.toString();
    }



    
}