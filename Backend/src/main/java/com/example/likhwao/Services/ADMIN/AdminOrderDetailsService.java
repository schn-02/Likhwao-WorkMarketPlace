package com.example.likhwao.Services.ADMIN;

import com.example.likhwao.DTO.ADMIN.AdminOrderDetailsResponseDto;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Repository.ADMIN.AdminDetailsRepository;
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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AdminOrderDetailsService {

    private final UserOrdersDetailsEntityRepository orderRepository;

    @Autowired
    private AdminDetailsRepository adminDetailsRepository;

    public AdminOrderDetailsService(
            UserOrdersDetailsEntityRepository orderRepository
    ) {
        this.orderRepository = orderRepository;
    }

    @Transactional(readOnly = true)
    public AdminOrderDetailsResponseDto getOrderDetails(
            Long orderId,
            String authorizationHeader
    ) throws Exception {

        verifyAdminToken(authorizationHeader);

        UserOrdersDetailsEntity order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        Firestore firestore = FirestoreClient.getFirestore();

        Map<String, Object> orderFsData = getDocumentData(
                firestore.collection("orders").document(orderId.toString())
        );

        // Latest writer submission
        Map<String, Object> submissionData = getLatestWriterSubmissionData(
                firestore, orderId
        );

        AdminOrderDetailsResponseDto response =
                new AdminOrderDetailsResponseDto("success", "Order details fetched successfully");

        // ── Order IDs ────────────────────────────────────────────────────────
        response.setOrderId(order.getId()); 

        // ── Order Status ──────────────────────────────────────────────────────
        response.setOrderStatus(firstNonBlank(
                order.getOrderStatus(),
                orderFsData.get("orderStatus"),
                orderFsData.get("status")
        )
        );

        response.setWriterAssignmentStatus( firstNonBlank(
                order.getWriterAssignmentStatus(),
                orderFsData.get("writerAssignmentStatus")
        ));
        response.setStatusLabel( firstNonBlank(orderFsData.get("statusLabel")));

        // ── User Details ──────────────────────────────────────────────────────
        response.setUserFirebaseUid ( firstNonBlank(
                order.getUserFirebaseUid(),
                orderFsData.get("userFirebaseUid")
        )
        );

        response.setUserName( firstNonBlank(
                order.getUserName(),
                orderFsData.get("userName")
        ));

        response.setUserNumber( firstNonBlank(
                order.getUserNumber(),
                orderFsData.get("userNumber")
        )
        );

        // ── Writer Details ────────────────────────────────────────────────────
        response.setWriterFirebaseUid( firstNonBlank(
                order.getWriterFirebaseUid(),
                orderFsData.get("writerFirebaseUid")
        )
        );

        response.setWriterName( firstNonBlank(
                orderFsData.get("writerName"),
                "Writer Not Assigned"
        )
        );

        // ── File Details ──────────────────────────────────────────────────────
        response.setUserFilePath(firstNonBlank(
        order.getUserFilePath(),
        orderFsData.get("userFilePath")
));

response.setFileSize(order.getFileSize());

response.setFilePageCount(firstInteger(
        order.getFilePageCount(),
        orderFsData.get("filePageCount")
));

// ── Writer Submission ─────────────────────────────────────────────────

response.setWriterSubmissionVersion(firstNonBlank(
        submissionData.get("documentId")
));

response.setWriterSubmissionFileName(firstNonBlank(
        submissionData.get("fileName"),
        submissionData.get("writerFileName"),
        submissionData.get("submissionFileName")
));

response.setWriterSubmissionFileUrl(firstNonBlank(
        submissionData.get("fileUrl"),
        submissionData.get("writerFileUrl"),
        submissionData.get("submissionFileUrl"),
        submissionData.get("downloadUrl"),
        submissionData.get("uploadedFileUrl")
));

response.setWriterSubmissionFilePath(firstNonBlank(
        submissionData.get("filePath"),
        submissionData.get("writerFilePath"),
        submissionData.get("submissionFilePath")
));

response.setWriterSubmissionVideoUrl(firstNonBlank(
        submissionData.get("videoUrl"),
        submissionData.get("writerVideoUrl"),
        submissionData.get("submissionVideoUrl")
));

response.setWriterSubmissionText(firstNonBlank(
        submissionData.get("text"),
        submissionData.get("message"),
        submissionData.get("description"),
        submissionData.get("writerNote")
));

response.setWriterSubmittedAt(toText(firstNonBlank(
        submissionData.get("createdAtTimestamp"),
        submissionData.get("uploadedAtTimestamp"),
        submissionData.get("submittedAtTimestamp")
)));

// ── Work Details ──────────────────────────────────────────────────────

response.setTypeOfWork(firstNonBlank(
        order.getTypeOfWork(),
        orderFsData.get("typeOfWork")
));

response.setSelectedLanguage(firstNonBlank(
        order.getLanguageSelectedChips(),
        orderFsData.get("selectedLanguage")
));

response.setSelectedInkColor(firstNonBlank(
        order.getSelectedInkColor(),
        orderFsData.get("selectedInkColor"),
        orderFsData.get("InkColor")
));

response.setSelectedNotebook(firstNonBlank(
        order.getSelectedNotebook(),
        orderFsData.get("selectedNotebook"),
        orderFsData.get("NotebookType")
));

response.setWriterSuggestionText(firstNonBlank(
        order.getWriterSuggestionText(),
        orderFsData.get("writerSuggestionText")
));

response.setWorkToBeDone(firstNonBlank(
        order.getWorkToBeDone(),
        orderFsData.get("workToBeDone")
));

// ── Delivery Details ──────────────────────────────────────────────────

response.setDeliveryPickupOption(firstNonBlank(
        order.getDeliveryPickupOption(),
        orderFsData.get("deliveryPickupOption")
));

response.setDeliveryAddress(firstNonBlank(
        order.getDeliveryAddress(),
        orderFsData.get("deliveryAddress")
));



// ── Deadline & Urgency ────────────────────────────────────────────────

response.setUrgency(firstNonBlank(
        order.getSelectedDeadLineUrgency(),
        orderFsData.get("urgency"),
        orderFsData.get("selectedDeadLineUrgency")
));

response.setDeadline(firstNonBlank(
        order.getSelectedDate() == null ? null : order.getSelectedDate().toString(),
        orderFsData.get("deadline"),
        orderFsData.get("selectedDate")
));

// ── Pricing ───────────────────────────────────────────────────────────

response.setOrderPageCountAmount(firstInteger(
        order.getOrderPageCountAmount(),
        orderFsData.get("orderPageCountAmount")
));

response.setUrgencyAmount(firstInteger(
        order.getUrgencyAmount(),
        orderFsData.get("urgencyAmount")
));

response.setDeliveryChargesAmount(firstInteger(
        order.getDeliveryChargesAmount(),
        orderFsData.get("deliveryChargesAmount")
));

response.setPlatformFeeAmount(firstInteger(
        order.getPlatformFeeAmount(),
        orderFsData.get("platformFeeAmount")
));

response.setNoteBookChargesAmount(firstInteger(
        order.getNoteBookChargesAmount(),
        orderFsData.get("noteBookChargesAmount")
));

response.setTotalOrderAmount(firstInteger(
        order.getTotalOrderAmount(),
        orderFsData.get("totalOrderAmount")
));

// ── Payment ───────────────────────────────────────────────────────────

response.setPaymentStatus(firstNonBlank(
        order.getPaymentStatus(),
        orderFsData.get("paymentStatus")
));

response.setPaymentMethod(firstNonBlank(
        order.getPaymentMethod(),
        orderFsData.get("paymentMethod")
));

response.setPaymentBank(firstNonBlank(
        order.getPaymentBank(),
        orderFsData.get("paymentBank")
));

// ── Timestamps ────────────────────────────────────────────────────────

response.setOrderCreatedAt(
        order.getOrderCreatedAt() == null
                ? null
                : order.getOrderCreatedAt().toString()
);

response.setOrderCompletedAt(
        order.getOrderCompletedAt() == null
                ? null
                : order.getOrderCompletedAt().toString()
);
        return response;
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private void verifyAdminToken(String authorizationHeader) throws Exception {
        if (authorizationHeader == null ||
                !authorizationHeader.startsWith("Bearer ")) {
            throw new RuntimeException("Unauthorized admin");
        }

        String idToken = authorizationHeader.substring(7).trim();

        if (idToken.isEmpty()) {
            throw new RuntimeException("Unauthorized admin");
        }

        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);

        if (decodedToken.getUid() == null ||
                decodedToken.getUid().trim().isEmpty()) {
            throw new RuntimeException("Unauthorized admin");
        }
    }

    private Map<String, Object> getDocumentData(DocumentReference ref) {
        try {
            DocumentSnapshot snapshot = ref.get().get();
            if (!snapshot.exists() || snapshot.getData() == null) {
                return new HashMap<>();
            }
            return new HashMap<>(snapshot.getData());
        } catch (Exception e) {
            return new HashMap<>();
        }
    }

    private Map<String, Object> getLatestWriterSubmissionData(
            Firestore firestore,
            Long orderId
    ) {
        try {
            QuerySnapshot snapshot = firestore
                    .collection("orders")
                    .document(orderId.toString())
                    .collection("writerSubmission")
                    .get()
                    .get();

            List<QueryDocumentSnapshot> docs = snapshot.getDocuments();

            if (docs == null || docs.isEmpty()) return new HashMap<>();

            // Latest version find karo
            QueryDocumentSnapshot latestDoc = docs.get(0);
            int latestVersion = parseVersionNumber(latestDoc.getId());

            for (QueryDocumentSnapshot doc : docs) {
                int current = parseVersionNumber(doc.getId());
                if (current > latestVersion) {
                    latestVersion = current;
                    latestDoc = doc;
                }
            }

            Map<String, Object> data = new HashMap<>(latestDoc.getData());
            data.put("documentId", latestDoc.getId());
            return data;

        } catch (Exception e) {
            return new HashMap<>();
        }
    }

    private int parseVersionNumber(String documentId) {
        try {
            if (documentId == null) return 0;
            String clean = documentId.toLowerCase().replace("v", "").trim();
            return Integer.parseInt(clean);
        } catch (Exception e) {
            return 0;
        }
    }

    private String firstNonBlank(Object... values) {
        if (values == null) return null;
        for (Object value : values) {
            if (value == null) continue;
            String text = value.toString();
            if (!text.trim().isEmpty() && !text.equalsIgnoreCase("null")) {
                return text;
            }
        }
        return null;
    }

    private Integer firstInteger(Object... values) {
        if (values == null) return null;
        for (Object value : values) {
            if (value == null) continue;
            if (value instanceof Integer) return (Integer) value;
            if (value instanceof Long) return ((Long) value).intValue();
            try {
                return Integer.parseInt(value.toString());
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    private String toText(Object value) {
        if (value == null) return null;
        return value.toString();
    }
}