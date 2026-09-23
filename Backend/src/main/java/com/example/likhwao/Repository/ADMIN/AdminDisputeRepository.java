package com.example.likhwao.Repository.ADMIN;


import com.example.likhwao.Entity.ADMIN.AdminDisputeEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface AdminDisputeRepository extends JpaRepository<AdminDisputeEntity, Long> {

    boolean existsByOrderIdAndDisputeStatusIn(
            Long orderId,
            Collection<String> disputeStatuses
    );

    List<AdminDisputeEntity> findByDisputeStatusInOrderByCreatedAtDesc(
            Collection<String> disputeStatuses
    );
}