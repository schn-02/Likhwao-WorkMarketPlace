package com.example.likhwao.Services.USER;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Hex;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.example.likhwao.Entity.USER.UserDetailsEntity;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Model.PaymentVerificationRequestModal;
import com.example.likhwao.Repository.USER.UserDetailsEntityRepository;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;

import jakarta.transaction.Transactional;

@Service
public class UserPaymentService {

    @Value("${razorpay.key_secret}")
    private String razorpaySecret;

    @Value("${razorpay.key_id}")
    private String razorpayKeyId;

    @Autowired
    private UserOrdersDetailsEntityRepository orderRepository;

    @Autowired
    private UserDetailsEntityRepository userDetailsEntityRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Transactional
    public void verifyPayment(PaymentVerificationRequestModal request, String token) {

        try {
            if (request == null) {
                throw new RuntimeException("Invalid payment request");
            }

            if (token == null || !token.startsWith("Bearer ")) {
                throw new RuntimeException("Unauthorized or token is null");
            }

            token = token.substring(7);

            FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
            String uid = decoded.getUid();

            if (request.getRazorpayOrderId() == null ||
                    request.getRazorpayOrderId().trim().isEmpty()) {
                throw new RuntimeException("Razorpay order id is required");
            }

            if (request.getRazorpayPaymentId() == null ||
                    request.getRazorpayPaymentId().trim().isEmpty()) {
                throw new RuntimeException("Razorpay payment id is required");
            }

            if (request.getRazorpaySignature() == null ||
                    request.getRazorpaySignature().trim().isEmpty()) {
                throw new RuntimeException("Razorpay signature is required");
            }

            String generatedSignature = generateSignature(
                    request.getRazorpayOrderId(),
                    request.getRazorpayPaymentId()
            );

            System.out.println("Payload: '" + request.getRazorpayOrderId() + "|" + request.getRazorpayPaymentId() + "'");
            System.out.println("Generated Signature: '" + generatedSignature + "'");
            System.out.println("Received Signature : '" + request.getRazorpaySignature() + "'");

            if (!generatedSignature.equalsIgnoreCase(request.getRazorpaySignature().trim())) {
                System.out.println("Invalid signature");
                throw new RuntimeException("Invalid payment signature");
            }

            UserDetailsEntity user = userDetailsEntityRepository
                    .findByFirebaseUid(uid)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            UserOrdersDetailsEntity order = orderRepository
                    .findByRazorpayOrderId(request.getRazorpayOrderId())
                    .orElseThrow(() -> new RuntimeException("Order not found"));

            if (order.getUserFirebaseUid() == null ||
                    !order.getUserFirebaseUid().equals(uid)) {
                throw new RuntimeException("Unauthorized user for this order");
            }

            boolean alreadyPaid = isOrderAlreadyPaid(order);

            if (!alreadyPaid) {
                updateUserStatsAfterPayment(user, order);
            }

            Map<String, String> paymentDetails = fetchRazorpayPaymentDetails(
                    request.getRazorpayPaymentId()
            );

            String paymentMethod = paymentDetails.get("method");
            String paymentBank = paymentDetails.get("bank");

            order.setPaymentId(request.getRazorpayPaymentId());
            order.setPaymentStatus("PAID");
            order.setOrderStatus("PAID");

            order.setPaymentMethod(paymentMethod);
            order.setPaymentBank(paymentBank);

            orderRepository.save(order);
            userDetailsEntityRepository.save(user);

            updatePaymentStatusInFirebase(order, user);

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Cannot save payment data please try again", e);
        }
    }

    private boolean isOrderAlreadyPaid(UserOrdersDetailsEntity order) {

        String paymentStatus = "";

        if (order.getPaymentStatus() != null) {
            paymentStatus = order.getPaymentStatus().trim().toUpperCase();
        }

        String orderStatus = "";

        if (order.getOrderStatus() != null) {
            orderStatus = order.getOrderStatus().trim().toUpperCase();
        }

        return "PAID".equals(paymentStatus)
                || "SUCCESS".equals(paymentStatus)
                || "CAPTURED".equals(paymentStatus)
                || "PAID".equals(orderStatus);
    }

    private void updateUserStatsAfterPayment(
            UserDetailsEntity user,
            UserOrdersDetailsEntity order
    ) {
        Integer currentSpent = user.getTotalSpent();

        if (currentSpent == null) {
            currentSpent = 0;
        }

        Integer currentOrders = user.getTotalOrders();

        if (currentOrders == null) {
            currentOrders = 0;
        }

        Integer orderAmount = order.getTotalOrderAmount();

        if (orderAmount == null) {
            orderAmount = 0;
        }

        user.setTotalOrders(currentOrders + 1);
        user.setTotalSpent(currentSpent + orderAmount);
    }

    private void updatePaymentStatusInFirebase(
            UserOrdersDetailsEntity order,
            UserDetailsEntity user
    ) {
        try {
            Firestore db = FirestoreClient.getFirestore();

            Timestamp now = Timestamp.now();

            Map<String, Object> map = new HashMap<>();

            map.put("paymentStatus", "PAID");
            map.put("paymentRequired", false);
            map.put("orderStatus", "PAID");
            map.put("paidAtTimestamp", now);
            map.put("updatedAtTimestamp", now);

            map.put("paymentId", order.getPaymentId());
            map.put("paymentMethod", order.getPaymentMethod());
            map.put("paymentBank", order.getPaymentBank());

            map.put("userTotalOrders", user.getTotalOrders());
            map.put("userTotalSpent", user.getTotalSpent());

            db.collection("orders")
                    .document(order.getId().toString())
                    .update(map)
                    .get();

            System.out.println("Firebase payment status updated for order: " + order.getId());

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Firebase payment update failed for order: " + order.getId(), e);
        }
    }

    private Map<String, String> fetchRazorpayPaymentDetails(String paymentId) {
        Map<String, String> paymentMap = new HashMap<>();

        try {
            if (paymentId == null || paymentId.trim().isEmpty()) {
                System.out.println("Payment id is empty, cannot fetch Razorpay payment details");
                return paymentMap;
            }

            String apiUrl = "https://api.razorpay.com/v1/payments/" + paymentId.trim();

            URL url = new URL(apiUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();

            connection.setRequestMethod("GET");
            connection.setConnectTimeout(15000);
            connection.setReadTimeout(15000);

            String auth = razorpayKeyId + ":" + razorpaySecret;

            String encodedAuth = Base64.getEncoder()
                    .encodeToString(auth.getBytes(StandardCharsets.UTF_8));

            connection.setRequestProperty("Authorization", "Basic " + encodedAuth);
            connection.setRequestProperty("Content-Type", "application/json");

            int responseCode = connection.getResponseCode();

            String responseBody = readResponse(connection, responseCode);

            System.out.println("Razorpay Payment Fetch Status: " + responseCode);
            System.out.println("Razorpay Payment Fetch Body: " + responseBody);

            if (responseCode < 200 || responseCode >= 300) {
                System.out.println("Razorpay payment fetch failed");
                return paymentMap;
            }

            JsonNode jsonNode = objectMapper.readTree(responseBody);

            String method = getJsonText(jsonNode, "method");
            String bank = getJsonText(jsonNode, "bank");

            paymentMap.put("method", method);
            paymentMap.put("bank", bank);

            System.out.println("Payment Method: " + method);
            System.out.println("Payment Bank: " + bank);

            connection.disconnect();

            return paymentMap;

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Unable to fetch Razorpay payment details, payment will still be saved");
            return paymentMap;
        }
    }

    private String readResponse(HttpURLConnection connection, int responseCode) {
        try {
            BufferedReader reader;

            if (responseCode >= 200 && responseCode < 300) {
                reader = new BufferedReader(
                        new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8)
                );
            } else {
                if (connection.getErrorStream() == null) {
                    return "";
                }

                reader = new BufferedReader(
                        new InputStreamReader(connection.getErrorStream(), StandardCharsets.UTF_8)
                );
            }

            StringBuilder response = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                response.append(line);
            }

            reader.close();

            return response.toString();

        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

    private String getJsonText(JsonNode jsonNode, String key) {
        if (jsonNode == null || jsonNode.get(key) == null || jsonNode.get(key).isNull()) {
            return null;
        }

        String value = jsonNode.get(key).asText();

        if (value == null || value.trim().isEmpty() || "null".equalsIgnoreCase(value.trim())) {
            return null;
        }

        return value.trim();
    }

    private String generateSignature(String orderId, String paymentId) {
        try {
            String payload = orderId + "|" + paymentId;

            Mac mac = Mac.getInstance("HmacSHA256");

            SecretKeySpec secretKey = new SecretKeySpec(
                    razorpaySecret.getBytes(StandardCharsets.UTF_8),
                    "HmacSHA256"
            );

            mac.init(secretKey);

            byte[] hash = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));

            return Hex.encodeHexString(hash);

        } catch (Exception e) {
            throw new RuntimeException("Signature generation failed", e);
        }
    }
}