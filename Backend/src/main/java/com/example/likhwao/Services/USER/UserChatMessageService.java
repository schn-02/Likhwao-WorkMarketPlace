package com.example.likhwao.Services.USER;


import com.example.likhwao.DTO.USER.ChatMessageRequesDTO;
import com.example.likhwao.DTO.USER.ChatMessageResponse;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

@Service
public class UserChatMessageService {

    private final UserOrdersDetailsEntityRepository userOrdersDetailsEntityRepository;

    public UserChatMessageService(UserOrdersDetailsEntityRepository userOrdersDetailsEntityRepository) {
        this.userOrdersDetailsEntityRepository = userOrdersDetailsEntityRepository;
    }

    public ChatMessageResponse sendMessage(
            String authorizationHeader,
            ChatMessageRequesDTO request
    ) {
        validateRequest(request);

    

        String senderFirebaseUid = verifyFirebaseTokenAndGetUid(authorizationHeader);

        UserOrdersDetailsEntity order = userOrdersDetailsEntityRepository
                .findById(request.getOrderId())
                .orElseThrow(() -> new RuntimeException("Order not found"));

        validateOrderChatAccess(order, senderFirebaseUid, request);

        validateSafeMessage(request.getMessage());

        saveMessageToFirebase(senderFirebaseUid, request);

        return ChatMessageResponse.success("Message sent successfully");
    }

    private void validateRequest(ChatMessageRequesDTO request) {
        if (request == null) {
            throw new RuntimeException("Invalid request");
        }

        if (request.getOrderId() == null || request.getOrderId() <= 0) {
            throw new RuntimeException("Order ID is required");
        }

        if (request.getReceiverFirebaseUid() == null ||
                request.getReceiverFirebaseUid().trim().isEmpty()) {
            throw new RuntimeException("Receiver is required");
        }

        if (request.getMessage() == null ||
                request.getMessage().trim().isEmpty()) {
            throw new RuntimeException("Message cannot be empty");
        }

        if (request.getMessage().trim().length() > 500) {
            throw new RuntimeException("Message is too long");
        }
    }

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
            throw new RuntimeException("Unauthorized user");
        }
    }

    private void validateOrderChatAccess(
            UserOrdersDetailsEntity order,
            String senderFirebaseUid,
            ChatMessageRequesDTO request
    ) {
        if (order.getUserFirebaseUid() == null ||
                !order.getUserFirebaseUid().equals(senderFirebaseUid)) {
            throw new RuntimeException("You are not allowed to chat for this order");
        }

        if (order.getWriterFirebaseUid() == null ||
                !order.getWriterFirebaseUid().equals(request.getReceiverFirebaseUid())) {
            throw new RuntimeException("Invalid writer for this chat");
        }

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

        if (writerAssignmentStatus.equals("COMPLETED")) {
            throw new RuntimeException("Chat is closed after order completion");
        }

        if (writerAssignmentStatus.equals("REJECT")) {
            throw new RuntimeException("Chat is not available for rejected order");
        }
    }

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
                "whatsapp",
                "whats app",
                "watsapp",
                "call me",
                "phone",
                "mobile",
                "number",
                "contact",
                "telegram",
                "instagram",
                "insta",
                "gmail",
                "email",
                "mail me",
                "dm me",
                "outside app",
                "Number Send karo",
                "direct deal"
        };

        for (String word : blockedWords) {
            if (text.contains(word)) {
                throw new RuntimeException("Sharing contact details is not allowed");
            }
        }
    }

    private void saveMessageToFirebase(
            String senderFirebaseUid,
            ChatMessageRequesDTO request
    ) {
        try {
            Firestore firestore = FirestoreClient.getFirestore();

            Map<String, Object> messageData = new HashMap<>();
            messageData.put("senderId", "USER_"+senderFirebaseUid);
            messageData.put("receiverId", "WRITER_"+request.getReceiverFirebaseUid());
            messageData.put("message", request.getMessage().trim());
            messageData.put("timestamp", Timestamp.now());
            messageData.put("clientMessageId", request.getClientMessageId());
            messageData.put("sentByBackend", true);
            messageData.put("isRead", false);
            messageData.put("readAt", null);
            messageData.put("senderRole", "USER");
            messageData.put("receiverRole", "WRITER");
            messageData.put("senderFirebaseUid", senderFirebaseUid);
            messageData.put("receiverFirebaseUid", request.getReceiverFirebaseUid());

            firestore
                    .collection("chats")
                    .document(String.valueOf(request.getOrderId()))
                    .collection("messages")
                    .add(messageData)
                    .get();

        } catch (Exception e) {
            throw new RuntimeException("Message save failed");
        }
    }
}