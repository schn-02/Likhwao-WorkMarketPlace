package com.example.likhwao.Services.USER;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Entity.WRITER.OrderWriterActionEntity;
import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;
import com.example.likhwao.Entity.WRITER.WriterWorkEntity;
import com.example.likhwao.Model.UserOrderDetailsModal;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.example.likhwao.Repository.WRITER.OrderWriterActionEntityRepository;
import com.example.likhwao.Repository.WRITER.WriterWorkRepository;
import com.example.likhwao.Repository.WRITER.WritersDetailsEntityRepository;
import com.example.likhwao.Services.WRITER.WriterStatsService;
import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;

import jakarta.transaction.Transactional;

@Service
public class UserOrderStatusServices {

    @Autowired
    private WritersDetailsEntityRepository wder;

    @Autowired
    private UserOrdersDetailsEntityRepository uder;

    @Autowired
    private OrderWriterActionEntityRepository owaer;

    @Autowired
    private WriterWorkRepository wwr;

    @Autowired
    private WriterStatsService writerStatsService;

    @Transactional
    public void orderStatus(String token, UserOrderDetailsModal udm) {

        try {
            if (token == null || !token.startsWith("Bearer ")) {
                throw new RuntimeException("Invalid token");
            }

            token = token.substring(7);

            FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
            String uid = decoded.getUid();

            UserOrdersDetailsEntity order = uder.findById(udm.getId())
                    .orElseThrow(() -> new RuntimeException("Order not found"));

            if (order.getUserFirebaseUid() == null ||
                    !order.getUserFirebaseUid().equals(uid)) {
                throw new RuntimeException("Unauthorized user");
            }

            WriterWorkEntity workEntity = wwr.findbyOrderIdAndWriterWorkId(
                    udm.getWriterWorkId(),
                    udm.getId()
            );

            if (workEntity == null) {
                throw new RuntimeException("Writer work not found");
            }

            WriterDetailsEntity writerDetails = workEntity.getWriter();

            if (writerDetails == null || writerDetails.getId() == null) {
                throw new RuntimeException("Writer not found in work entity");
            }

            String status = normalizeStatus(udm.getWriterAssignmentStatus());

            if (!"COMPLETED".equals(status) && !"REQUEST_CHANGES".equals(status)) {
                throw new RuntimeException("Invalid status");
            }

            String oldOrderWriterStatus = normalizeStatus(order.getWriterAssignmentStatus());
            String oldWorkStatus = normalizeStatus(workEntity.getWriterAssignmentStatus());

            boolean alreadyCompleted =
                    "COMPLETED".equals(oldOrderWriterStatus)
                            || "COMPLETED".equals(oldWorkStatus);

            boolean alreadyRequestChanges =
                    "REQUEST_CHANGES".equals(oldOrderWriterStatus)
                            || "REQUEST_CHANGES".equals(oldWorkStatus);

            boolean isFirstTimeCompleted =
                    "COMPLETED".equals(status) && !alreadyCompleted;

            boolean isFirstTimeRequestChange =
                    "REQUEST_CHANGES".equals(status) && !alreadyRequestChanges;

            if ("REQUEST_CHANGES".equals(status)) {

                if (udm.getUserRequestChangeDescription() == null ||
                        udm.getUserRequestChangeDescription().trim().isEmpty()) {
                    throw new RuntimeException("Change request description is required");
                }

                workEntity.setUserRequestChangeDescription(
                        udm.getUserRequestChangeDescription().trim()
                );

                if (isFirstTimeRequestChange) {
                    updateWriterRequestChangeCount(writerDetails);
                }
            }

            order.setWriterAssignmentStatus(status);
            workEntity.setWriterAssignmentStatus(status);
LocalDateTime actionTime = LocalDateTime.now();

if ("COMPLETED".equals(status)) {
    order.setOrderStatus("COMPLETED");

    if (isFirstTimeCompleted && order.getOrderCompletedAt() == null) {
        order.setOrderCompletedAt(actionTime);
    }
}

            if (isFirstTimeCompleted) {
                updateWriterStatsOnCompletedOrder(order, writerDetails);
            }

            if (isFirstTimeCompleted || isFirstTimeRequestChange) {
                writerStatsService.recalculateWriterSuccessRate(writerDetails);
            }

            wwr.save(workEntity);
            uder.save(order);
            wder.save(writerDetails);

            OrderWriterActionEntity orderWriterAction = owaer
                    .findByWriterAndOrder(writerDetails, order)
                    .orElseGet(() -> {
                        OrderWriterActionEntity newEntity = new OrderWriterActionEntity();
                        newEntity.setOrder(order);
                        newEntity.setWriter(writerDetails);
                        newEntity.setUser(order.getUser());
                        newEntity.setActionTime(LocalDateTime.now());
                        return newEntity;
                    });

            orderWriterAction.setAction(status);
            owaer.save(orderWriterAction);

           updateFirebaseAfterUserAction(
        order,
        workEntity,
        status,
        udm.getUserRequestChangeDescription(),
        writerDetails,
        isFirstTimeCompleted,
        actionTime
);

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Order status update failed", e);
        }
    }

    private String normalizeStatus(String status) {
        if (status == null) {
            return "";
        }

        return status.trim().toUpperCase();
    }

    private void updateWriterRequestChangeCount(WriterDetailsEntity writerDetails) {

        Integer totalRequestChanges = writerDetails.getTotalRequestChanges();

        if (totalRequestChanges == null) {
            totalRequestChanges = 0;
        }

        writerDetails.setTotalRequestChanges(totalRequestChanges + 1);
    }

    private void updateWriterStatsOnCompletedOrder(
            UserOrdersDetailsEntity order,
            WriterDetailsEntity writerDetails
    ) {
        Integer currentEarning = writerDetails.getWriterTotalEarning();

        if (currentEarning == null) {
            currentEarning = 0;
        }

        Integer writerEarning = order.getTotalOrderAmount();

        if (writerEarning == null) {
            writerEarning = 0;
        }

        writerDetails.setWriterTotalEarning(currentEarning + writerEarning);

        Integer totalOrders = writerDetails.getTotalOrders();

        if (totalOrders == null) {
            totalOrders = 0;
        }

        writerDetails.setTotalOrders(totalOrders + 1);
    }

    @Transactional
    public void updateFirebaseAfterUserAction(
            UserOrdersDetailsEntity order,
        WriterWorkEntity workEntity,
        String status,
        String changeRequestText,
        WriterDetailsEntity writerDetails,
        boolean isFirstTimeCompleted,
        LocalDateTime actionTime
    ) {
        try {
            Firestore db = FirestoreClient.getFirestore();

            String orderId = order.getId().toString();
            String now = actionTime.toString();
Timestamp nowTimestamp = Timestamp.now();

            Map<String, Object> orderUpdateMap = new HashMap<>();

            orderUpdateMap.put("status", status);
            orderUpdateMap.put("writerAssignmentStatus", status);
            orderUpdateMap.put("updatedAt", now);
            orderUpdateMap.put("updatedAtTimestamp", nowTimestamp);

            orderUpdateMap.put("writerTotalOrders", writerDetails.getTotalOrders());
            orderUpdateMap.put("writerTotalRequestChanges", writerDetails.getTotalRequestChanges());
            orderUpdateMap.put("writerAverageRating", writerDetails.getAverageRating());
            orderUpdateMap.put("writerSuccessRate", writerDetails.getSuccessRate());
            orderUpdateMap.put("writerTotalEarning", writerDetails.getWriterTotalEarning());

            if ("REQUEST_CHANGES".equals(status)) {
                orderUpdateMap.put("latestSubmissionStatus", "CHANGES_REQUESTED");
                orderUpdateMap.put("latestSubmissionChangeRequestText", changeRequestText);
                orderUpdateMap.put("latestSubmissionChangeRequestedAt", now);
                orderUpdateMap.put(
                        "latestSubmissionChangeRequestedAtTimestamp",
                        com.google.cloud.Timestamp.now()
                );
                orderUpdateMap.put("hasWriterSubmission", true);
            }

            if ("COMPLETED".equals(status)) {
    orderUpdateMap.put("orderStatus", "COMPLETED");
    orderUpdateMap.put("latestSubmissionStatus", "COMPLETED");
    orderUpdateMap.put("hasWriterSubmission", true);

    if (isFirstTimeCompleted) {
        orderUpdateMap.put("latestSubmissionAcceptedAt", now);
        orderUpdateMap.put("latestSubmissionAcceptedAtTimestamp", nowTimestamp);

        orderUpdateMap.put("completedAt", now);
        orderUpdateMap.put("completedAtTimestamp", nowTimestamp);

        orderUpdateMap.put("orderCompletedAt", now);
        orderUpdateMap.put("orderCompletedAtTimestamp", nowTimestamp);
    }
}

            db.collection("orders")
                    .document(orderId)
                    .update(orderUpdateMap)
                    .get();

            ApiFuture<QuerySnapshot> future = db.collection("orders")
                    .document(orderId)
                    .collection("writerSubmission")
                    .whereEqualTo("isLatest", true)
                    .get();

            QuerySnapshot querySnapshot = future.get();

            if (!querySnapshot.isEmpty()) {
                for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {

                    Map<String, Object> submissionUpdateMap = new HashMap<>();

                    submissionUpdateMap.put("status", status);
                    submissionUpdateMap.put("updatedAt", now);
                    submissionUpdateMap.put(
                            "updatedAtTimestamp",
                            nowTimestamp
                    );

                    if ("REQUEST_CHANGES".equals(status)) {
                        submissionUpdateMap.put("submissionStatus", "CHANGES_REQUESTED");
                        submissionUpdateMap.put("changeRequestText", changeRequestText);
                        submissionUpdateMap.put("changeRequestedAt", now);
                        submissionUpdateMap.put(
                                "changeRequestedAtTimestamp",
                                com.google.cloud.Timestamp.now()
                        );
                    }

                  if ("COMPLETED".equals(status)) {
    submissionUpdateMap.put("submissionStatus", "COMPLETED");

    if (isFirstTimeCompleted) {
        submissionUpdateMap.put("acceptedAt", now);
        submissionUpdateMap.put("acceptedAtTimestamp", nowTimestamp);
    }
}

                    document.getReference()
                            .update(submissionUpdateMap)
                            .get();
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Firebase update failed after user action", e);
        }
    }
}