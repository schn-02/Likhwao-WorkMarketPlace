package com.example.likhwao.Services.WRITER;

import org.springframework.stereotype.Service;

import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;

@Service
public class WriterStatsService {

    public void recalculateWriterSuccessRate(WriterDetailsEntity writerDetails) {

        if (writerDetails == null) {
            return;
        }

        Integer completedOrders = writerDetails.getTotalOrders();

        if (completedOrders == null || completedOrders <= 0) {
            writerDetails.setSuccessRate(0.0);
            return;
        }

        Double averageRating = writerDetails.getAverageRating();

        if (averageRating == null || averageRating <= 0.0) {
            writerDetails.setSuccessRate(0.0);
            return;
        }

        if (averageRating > 5.0) {
            averageRating = 5.0;
        }

        Integer totalRequestChanges = writerDetails.getTotalRequestChanges();

        if (totalRequestChanges == null) {
            totalRequestChanges = 0;
        }

        double ratingScore = (averageRating / 5.0) * 100.0;

        double requestChangeRatio =
                (double) totalRequestChanges / completedOrders;

        double revisionPenalty = requestChangeRatio * 10.0;

        double successRate = ratingScore - revisionPenalty;

        if (successRate < 0.0) {
            successRate = 0.0;
        }

        if (successRate > 100.0) {
            successRate = 100.0;
        }

        successRate = Math.round(successRate * 10.0) / 10.0;

        writerDetails.setSuccessRate(successRate);
    }
}