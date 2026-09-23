package com.example.likhwao.Services.WRITER;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.likhwao.DTO.WRITER.HomeStatsResponse;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;

import jakarta.transaction.Transactional;

@Service
public class HomeStatsDataService {

    @Autowired
    private UserOrdersDetailsEntityRepository orderRepository;

    @Transactional
    public HomeStatsResponse getStats(String token) {

        try {
            String cleanToken = token.replace("Bearer ", "").trim();

            FirebaseToken decodedToken = FirebaseAuth.getInstance()
                    .verifyIdToken(cleanToken);

            String writerFirebaseUid = decodedToken.getUid();

        int activeOrders = orderRepository.countWriterOrdersByStatus(
        writerFirebaseUid,
        "ACCEPTED"
);

int reviewOrders = orderRepository.countWriterOrdersByStatus(
        writerFirebaseUid,
        "REVIEW"
);

Double totalEarning = orderRepository.getTotalEarningByWriterFirebaseUid(
        writerFirebaseUid
);
            return new HomeStatsResponse(
                    activeOrders,
                    totalEarning == null ? 0.0 : totalEarning,
                    reviewOrders
            );

        } catch (Exception e) {
            throw new RuntimeException("Failed to fetch writer home stats: " + e.getMessage());
        }
    }
}