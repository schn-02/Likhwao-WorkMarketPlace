package com.example.likhwao.Repository.WRITER;


import org.springframework.data.jpa.repository.JpaRepository;

import com.example.likhwao.Entity.WRITER.WriterFeedbackEntity;

import java.util.List;
import java.util.Optional;

public interface WriterFeedbackRepository extends JpaRepository<WriterFeedbackEntity, Long> {

    boolean existsByOrderId(Long orderId);

    Optional<WriterFeedbackEntity> findByOrderId(Long orderId);

    List<WriterFeedbackEntity> findByWriterId(Long writerId);

    List<WriterFeedbackEntity> findByUserId(Long userId);
}