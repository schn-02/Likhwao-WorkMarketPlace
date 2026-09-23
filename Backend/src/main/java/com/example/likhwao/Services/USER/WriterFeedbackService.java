package com.example.likhwao.Services.USER;

import com.example.likhwao.DTO.USER.WriterFeedbackResponse;
import com.example.likhwao.DTO.WRITER.WriterFeedbackRequestDTO;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;
import com.example.likhwao.Entity.WRITER.WriterFeedbackEntity;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.example.likhwao.Repository.WRITER.WriterFeedbackRepository;
import com.example.likhwao.Repository.WRITER.WritersDetailsEntityRepository;
import com.example.likhwao.Services.WRITER.WriterStatsService;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@Service
public class WriterFeedbackService {

    private final WriterFeedbackRepository writerFeedbackRepository;
    private final UserOrdersDetailsEntityRepository userOrdersDetailsEntityRepository;
    private final WritersDetailsEntityRepository writersDetailsEntityRepository;
    private final WriterStatsService writerStatsService;

    public WriterFeedbackService(
            WriterFeedbackRepository writerFeedbackRepository,
            UserOrdersDetailsEntityRepository userOrdersDetailsEntityRepository,
            WritersDetailsEntityRepository writersDetailsEntityRepository,
            WriterStatsService writerStatsService
    ) {
        this.writerFeedbackRepository = writerFeedbackRepository;
        this.userOrdersDetailsEntityRepository = userOrdersDetailsEntityRepository;
        this.writersDetailsEntityRepository = writersDetailsEntityRepository;
        this.writerStatsService = writerStatsService;
    }

    @Transactional
    public WriterFeedbackResponse submitFeedback(WriterFeedbackRequestDTO request) {

        validateRequest(request);

        UserOrdersDetailsEntity order = userOrdersDetailsEntityRepository
                .findById(request.getOrderId())
                .orElseThrow(() -> new RuntimeException("Order not found"));

        validateOrderForFeedback(order, request);

        boolean alreadySubmitted = writerFeedbackRepository.existsByOrderId(request.getOrderId());

        if (alreadySubmitted) {
            throw new RuntimeException("Feedback already submitted for this order");
        }

        WriterDetailsEntity writer = order.getWriter();

        if (writer == null || writer.getId() == null) {
            throw new RuntimeException("Writer not found for this order");
        }

        WriterFeedbackEntity feedback = new WriterFeedbackEntity();

        feedback.setOrderId(request.getOrderId());
        feedback.setUserId(request.getUserId());
        feedback.setWriterId(request.getWriterId());
        feedback.setRating(request.getRating());
        feedback.setReviewText(request.getReviewText().trim());
        feedback.setAnonymous(request.getAnonymous() != null && request.getAnonymous());

        WriterFeedbackEntity savedFeedback = writerFeedbackRepository.save(feedback);

        updateWriterReviewStats(writer, request.getRating());

        updateFeedbackInFirebase(order, request, savedFeedback, writer);

        return WriterFeedbackResponse.success("Feedback submitted successfully");
    }

    private void validateRequest(WriterFeedbackRequestDTO request) {

        if (request == null) {
            throw new RuntimeException("Invalid feedback request");
        }

        if (request.getOrderId() == null || request.getOrderId() <= 0) {
            throw new RuntimeException("Order ID is required");
        }

        if (request.getUserId() == null || request.getUserId() <= 0) {
            throw new RuntimeException("User ID is required");
        }

        if (request.getWriterId() == null || request.getWriterId() <= 0) {
            throw new RuntimeException("Writer ID is required");
        }

        if (request.getRating() == null || request.getRating() < 1 || request.getRating() > 5) {
            throw new RuntimeException("Rating must be between 1 and 5");
        }

        if (request.getReviewText() == null || request.getReviewText().trim().isEmpty()) {
            throw new RuntimeException("Review text is required");
        }

        if (request.getReviewText().trim().length() > 1000) {
            throw new RuntimeException("Review text is too long");
        }
    }

    private void validateOrderForFeedback(
            UserOrdersDetailsEntity order,
            WriterFeedbackRequestDTO request
    ) {

        if (order.getUser() == null || order.getUser().getId() == null) {
            throw new RuntimeException("Order user not found");
        }

        if (!Objects.equals(order.getUser().getId(), request.getUserId())) {
            throw new RuntimeException("You are not allowed to give feedback for this order");
        }

        if (order.getWriter() == null || order.getWriter().getId() == null) {
            throw new RuntimeException("Writer not assigned for this order");
        }

        if (!Objects.equals(order.getWriter().getId(), request.getWriterId())) {
            throw new RuntimeException("Invalid writer for this order");
        }

        String orderStatus = "";

        if (order.getOrderStatus() != null) {
            orderStatus = order.getOrderStatus().trim().toUpperCase();
        }

        String writerAssignmentStatus = "";

        if (order.getWriterAssignmentStatus() != null) {
            writerAssignmentStatus = order.getWriterAssignmentStatus().trim().toUpperCase();
        }

        boolean isCompleted =
                "COMPLETED".equals(orderStatus)
                        || "COMPLETED".equals(writerAssignmentStatus);

        if (!isCompleted) {
            throw new RuntimeException("Feedback can be submitted only after order completion");
        }

        String paymentStatus = "";

        if (order.getPaymentStatus() != null) {
            paymentStatus = order.getPaymentStatus().trim().toUpperCase();
        }

        boolean paymentDone =
                "PAID".equals(paymentStatus)
                        || "SUCCESS".equals(paymentStatus)
                        || "CAPTURED".equals(paymentStatus);

        if (!paymentDone) {
            throw new RuntimeException("Feedback can be submitted only after payment completion");
        }
    }

    private void updateWriterReviewStats(
            WriterDetailsEntity writer,
            Integer newRating
    ) {
        Double currentAverageRating = writer.getAverageRating();

        if (currentAverageRating == null) {
            currentAverageRating = 0.0;
        }

        Integer currentTotalReviews = writer.getTotalReviews();

        if (currentTotalReviews == null) {
            currentTotalReviews = 0;
        }

        int updatedTotalReviews = currentTotalReviews + 1;

        double updatedAverageRating =
                ((currentAverageRating * currentTotalReviews) + newRating)
                        / updatedTotalReviews;

        updatedAverageRating = Math.round(updatedAverageRating * 10.0) / 10.0;

        writer.setAverageRating(updatedAverageRating);
        writer.setTotalReviews(updatedTotalReviews);

        writerStatsService.recalculateWriterSuccessRate(writer);

        writersDetailsEntityRepository.save(writer);
    }

    private void updateFeedbackInFirebase(
            UserOrdersDetailsEntity order,
            WriterFeedbackRequestDTO request,
            WriterFeedbackEntity savedFeedback,
            WriterDetailsEntity writer
    ) {
        try {
            Firestore firestore = FirestoreClient.getFirestore();

            Map<String, Object> feedbackData = new HashMap<>();

            feedbackData.put("feedbackGiven", true);
            feedbackData.put("feedbackId", savedFeedback.getFeedbackId());
            feedbackData.put("feedbackStatus", "SUBMITTED");

            feedbackData.put("writerRating", request.getRating());
            feedbackData.put("writerAverageRating", writer.getAverageRating());
            feedbackData.put("writerTotalReviews", writer.getTotalReviews());
            feedbackData.put("writerSuccessRate", writer.getSuccessRate());
            feedbackData.put("writerTotalRequestChanges", writer.getTotalRequestChanges());
            feedbackData.put("writerTotalOrders", writer.getTotalOrders());

            feedbackData.put(
                    "feedbackAnonymous",
                    request.getAnonymous() != null && request.getAnonymous()
            );

            feedbackData.put("feedbackSubmittedAt", Timestamp.now());
            feedbackData.put("feedbackReviewText", request.getReviewText().trim());

            feedbackData.put("feedbackUserId", request.getUserId());
            feedbackData.put("feedbackWriterId", request.getWriterId());

            if (order.getUserFirebaseUid() != null) {
                feedbackData.put("feedbackUserFirebaseUid", order.getUserFirebaseUid());
            }

            if (order.getWriterFirebaseUid() != null) {
                feedbackData.put("feedbackWriterFirebaseUid", order.getWriterFirebaseUid());
            }

            firestore
                    .collection("orders")
                    .document(String.valueOf(request.getOrderId()))
                    .update(feedbackData)
                    .get();

        } catch (Exception e) {
            throw new RuntimeException(
                    "Feedback saved in SQL but Firebase update failed: " + e.getMessage()
            );
        }
    }
}