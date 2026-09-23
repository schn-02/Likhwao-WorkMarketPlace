package com.example.likhwao.Services;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;

import com.example.likhwao.DTO.USER.ChatMessageRequesDTO;
import com.example.likhwao.DTO.USER.ChatMessageResponse;
import com.example.likhwao.Entity.ADMIN.AdminDetailsEntity;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Repository.ADMIN.AdminDetailsRepository;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;

@Service
public class ChatService {

    private final UserOrdersDetailsEntityRepository userOrdersDetailsEntityRepository;
    private final AdminDetailsRepository adminDetailsRepository;

    public ChatService(
            UserOrdersDetailsEntityRepository userOrdersDetailsEntityRepository,
            AdminDetailsRepository adminDetailsRepository
    ) {
        this.userOrdersDetailsEntityRepository = userOrdersDetailsEntityRepository;
        this.adminDetailsRepository = adminDetailsRepository;
    }

    public ChatMessageResponse sendMessage(
            String authorizationHeader,
            ChatMessageRequesDTO request
    ) {
        validateRequest(request);

        String currentFirebaseUid = verifyFirebaseTokenAndGetUid(authorizationHeader);

        UserOrdersDetailsEntity order = userOrdersDetailsEntityRepository
                .findById(request.getOrderId())
                .orElseThrow(() -> new RuntimeException("Order not found"));

        String role = checkRole(order, currentFirebaseUid);

       
        if ("USER".equals(role) && "toAdmin".equals(request.getChatTo())) {
            AdminDetailsEntity admin = adminDetailsRepository
                    .findAll()
                    .stream()
                    .findFirst()
                    .orElseThrow(() -> new RuntimeException("Admin not found"));
            request.setReceiverFirebaseUid(admin.getFirebaseUid());
        }

       if ("WRITER".equals(role) && "toAdmin".equals(request.getChatTo())) {
    AdminDetailsEntity admin = adminDetailsRepository
            .findAll().stream().findFirst()
            .orElseThrow(() -> new RuntimeException("Admin not found"));
    request.setReceiverFirebaseUid(admin.getFirebaseUid());
}

        validateOrderChatAccess(order, currentFirebaseUid, request, role);

        validateSafeMessage(request.getMessage());

        saveMessageToFirebase(currentFirebaseUid, request, role);

        return ChatMessageResponse.success("Message sent successfully");
    }

    // ── Validate Request

    private void validateRequest(ChatMessageRequesDTO request) {
        if (request == null) {
            throw new RuntimeException("Invalid request");
        }

        if (request.getOrderId() == null || request.getOrderId() <= 0) {
            throw new RuntimeException("Order ID is required");
        }

        if (request.getMessage() == null ||
                request.getMessage().trim().isEmpty()) {
            throw new RuntimeException("Message cannot be empty");
        }

        if (request.getMessage().trim().length() > 500) {
            throw new RuntimeException("Message is too long");
        }

        if (request.getClientMessageId() == null ||
                request.getClientMessageId().trim().isEmpty()) {
            throw new RuntimeException("Client message id is required");
        }

        boolean isUserToAdmin = "USER".equals(request.getRole())
                && "toAdmin".equals(request.getChatTo());

        boolean isWriterToAdmin = "WRITER".equals(request.getRole()) && "toAdmin".equals(request.getChatTo());
        

       if (!isUserToAdmin && !isWriterToAdmin) {
    if (request.getReceiverFirebaseUid() == null ||
            request.getReceiverFirebaseUid().trim().isEmpty()) {
        throw new RuntimeException("Receiver is required");
    }
}
    }

    // ── Verify Token ──────────────────────────────────────────────────────────

    private String verifyFirebaseTokenAndGetUid(String authorizationHeader) {
        try {
            if (authorizationHeader == null ||
                    !authorizationHeader.startsWith("Bearer ")) {
                throw new RuntimeException("Missing token");
            }

            String token = authorizationHeader.substring(7);

            FirebaseToken decodedToken = FirebaseAuth
                    .getInstance()
                    .verifyIdToken(token);

            return decodedToken.getUid();

        } catch (Exception e) {
            throw new RuntimeException("Unauthorized writer");
        }
    }

    // ── Check Role ────────────────────────────────────────────────────────────

    private String checkRole(UserOrdersDetailsEntity order, String currentFirebaseUid) {

        if (currentFirebaseUid.equals(order.getUserFirebaseUid())) {
            return "USER";
        }

        if (currentFirebaseUid.equals(order.getWriterFirebaseUid())) {
            return "WRITER";
        }

        boolean isAdmin = adminDetailsRepository
                .findByFirebaseUid(currentFirebaseUid)
                .isPresent();

        if (isAdmin) {
            return "ADMIN";
        }

        throw new RuntimeException("Unauthorized user");
    }

    // ── Validate Order Chat Access ────────────────────────────────────────────

    private void validateOrderChatAccess(
            UserOrdersDetailsEntity order,
            String currentFirebaseUid,
            ChatMessageRequesDTO request,
            String role
    ) {

        if ("USER".equals(role)) {

            if (!currentFirebaseUid.equals(order.getUserFirebaseUid())) {
                throw new RuntimeException("You are not allowed to chat for this order");
            }

            // ✅ FIX 3: USER→ADMIN allowed, skip writer check
            if ("toAdmin".equals(request.getChatTo())) {
                // Admin UID pehle se set ho chuka hai — bas return karo
                return;
            }

            // USER→WRITER: normal check
            if (!request.getReceiverFirebaseUid()
                    .equals(order.getWriterFirebaseUid())) {
                throw new RuntimeException("Invalid writer for this chat");
            }

            // Payment aur status check sirf USER→WRITER ke liye
            validatePaymentAndStatus(order);

        } else if ("WRITER".equals(role)) {

            if (!currentFirebaseUid.equals(order.getWriterFirebaseUid())) {
                throw new RuntimeException("You are not allowed to chat for this order");
            }

            if("toAdmin".equals(request.getChatTo()))
            {
                return;
            }

            if (!request.getReceiverFirebaseUid()
                    .equals(order.getUserFirebaseUid())) {
                throw new RuntimeException("Invalid user for this chat");
            }

            validatePaymentAndStatus(order);

        } else if ("ADMIN".equals(role)) {

            if ("toUser".equals(request.getChatTo())) {
                if (!request.getReceiverFirebaseUid()
                        .equals(order.getUserFirebaseUid())) {
                    throw new RuntimeException("Invalid User");
                }

            } else if ("toWriter".equals(request.getChatTo())) {
                if (!request.getReceiverFirebaseUid()
                        .equals(order.getWriterFirebaseUid())) {
                    throw new RuntimeException("Invalid Writer");
                }

            } else {
                throw new RuntimeException("Invalid chat target");
            }
        }
    }

    // ── Payment & Status Validation (USER and WRITER only) ───────────────────

    private void validatePaymentAndStatus(UserOrdersDetailsEntity order) {

        String paymentStatus = order.getPaymentStatus() == null
                ? ""
                : order.getPaymentStatus().trim().toUpperCase();

        boolean paymentDone =
                paymentStatus.equals("PAID") ||
                        paymentStatus.equals("SUCCESS") ||
                        paymentStatus.equals("CAPTURED");

        if (!paymentDone) {
            throw new RuntimeException("Chat is available only after payment");
        }

        String writerAssignmentStatus = order.getWriterAssignmentStatus() == null
                ? ""
                : order.getWriterAssignmentStatus().trim().toUpperCase();

        boolean chatAllowed =
                writerAssignmentStatus.equals("ACCEPT") ||
                        writerAssignmentStatus.equals("ACCEPTED") ||
                        writerAssignmentStatus.equals("IN_PROGRESS") ||
                        writerAssignmentStatus.equals("REVIEW") ||
                        writerAssignmentStatus.equals("REQUEST_CHANGES");

        if (!chatAllowed) {
            throw new RuntimeException("Chat is not available for this order status");
        }

        if (writerAssignmentStatus.equals("COMPLETED")) {
            throw new RuntimeException("Chat is closed after order completion");
        }

        if (writerAssignmentStatus.equals("REJECT")) {
            throw new RuntimeException("Chat is not available for rejected order");
        }
    }

    // ── Validate Safe Message ─────────────────────────────────────────────────

    private void validateSafeMessage(String message) {
        String text = message.trim().toLowerCase();

        Pattern phonePattern = Pattern.compile("(\\+91[\\s-]?)?[6-9][0-9]{9}");
        Pattern spacedPhonePattern = Pattern.compile("[6-9][0-9\\s-]{8,15}");
        Pattern emailPattern = Pattern.compile("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}");
        Pattern linkPattern = Pattern.compile("(http|https|www\\.|\\.com|\\.in|\\.net|\\.org|t\\.me|wa\\.me)");
        Pattern upiPattern = Pattern.compile("[a-zA-Z0-9._-]+@(upi|oksbi|okaxis|okhdfcbank|paytm|ybl|ibl|axl)");

        if (phonePattern.matcher(text).find()
                || spacedPhonePattern.matcher(text).find()
                || emailPattern.matcher(text).find()
                || linkPattern.matcher(text).find()
                || upiPattern.matcher(text).find()) {
            throw new RuntimeException("Sharing contact details is not allowed");
        }

        String[] blockedWords = {
                "whatsapp", "whats app", "watsapp", "call me",
                "phone", "mobile", "number", "contact",
                "telegram", "instagram", "insta", "gmail",
                "email", "mail me", "dm me", "outside app",
                "number send karo", "direct deal"
        };

        for (String word : blockedWords) {
            if (text.contains(word.toLowerCase())) {
                throw new RuntimeException("Sharing contact details is not allowed");
            }
        }
    }

    // ── Save Message To Firebase ──────────────────────────────────────────────

    private void saveMessageToFirebase(
            String currentFirebaseUid,
            ChatMessageRequesDTO request,
            String role
    ) {
        try {
            Firestore firestore = FirestoreClient.getFirestore();

            String senderRole;
            String receiverRole;
            String collectionName;
            String documentId;

            if ("USER".equals(role)) {

                // ✅ FIX 4: USER→ADMIN case
                if ("toAdmin".equals(request.getChatTo())) {
                    senderRole = "USER";
                    receiverRole = "ADMIN";
                    collectionName = "admin_user_chats";
                    documentId = "ADMIN_USER_" + request.getOrderId();

                } else {
                    // USER→WRITER (default)
                    senderRole = "USER";
                    receiverRole = "WRITER";
                    collectionName = "chats";
                    documentId = String.valueOf(request.getOrderId());
                }

            } else if ("WRITER".equals(role)) {

                if ("toAdmin".equals(request.getChatTo())) {
        senderRole = "WRITER";
        receiverRole = "ADMIN";
        collectionName = "admin_writer_chats";
        documentId = "ADMIN_WRITER_" + request.getOrderId();
    } else {
        senderRole = "WRITER";
        receiverRole = "USER";
        collectionName = "chats";
        documentId = String.valueOf(request.getOrderId());
    }

            } else {
                // ADMIN
                senderRole = "ADMIN";

                if ("toUser".equals(request.getChatTo())) {
                    receiverRole = "USER";
                    collectionName = "admin_user_chats";
                    documentId = "ADMIN_USER_" + request.getOrderId();

                } else if ("toWriter".equals(request.getChatTo())) {
                    receiverRole = "WRITER";
                    collectionName = "admin_writer_chats";
                    documentId = "ADMIN_WRITER_" + request.getOrderId();

                } else {
                    throw new RuntimeException("Invalid chat target");
                }
            }

            Map<String, Object> messageData = new HashMap<>();
            messageData.put("senderId", senderRole + "_" + currentFirebaseUid);
            messageData.put("receiverId", receiverRole + "_" + request.getReceiverFirebaseUid());
            messageData.put("message", request.getMessage().trim());
            messageData.put("timestamp", Timestamp.now());
            messageData.put("clientMessageId", request.getClientMessageId());
            messageData.put("sentByBackend", true);
            messageData.put("isRead", false);
            messageData.put("readAt", null);
            messageData.put("senderRole", senderRole);
            messageData.put("receiverRole", receiverRole);
            messageData.put("senderFirebaseUid", currentFirebaseUid);
            messageData.put("receiverFirebaseUid", request.getReceiverFirebaseUid());

            firestore
                    .collection(collectionName)
                    .document(documentId)
                    .collection("messages")
                    .add(messageData)
                    .get();

        } catch (Exception e) {
            throw new RuntimeException("Message save failed");
        }
    }
}