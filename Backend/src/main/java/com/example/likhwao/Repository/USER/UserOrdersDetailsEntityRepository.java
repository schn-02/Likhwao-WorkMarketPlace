package com.example.likhwao.Repository.USER;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;

import jakarta.persistence.LockModeType;

public interface UserOrdersDetailsEntityRepository  extends JpaRepository<UserOrdersDetailsEntity , Long>{

    Optional<UserOrdersDetailsEntity> findByRazorpayOrderId(String razorpayOrderId);

     
        @Query("""

            select o from UserOrdersDetailsEntity o
            where(
            o.user.id =:id
            AND
            o.writerAssignmentStatus <> 'REJECT' 
            AND
            o.writerAssignmentStatus <>'COMPLETED'
            AND
            o.paymentStatus ='PAID'
            )
                """)
        List<UserOrdersDetailsEntity> findByUserId(@Param("id") Long id );


    @Query("""

        Select o from UserOrdersDetailsEntity o
        where(
        o.writer.id =:id
        AND
        o.writerAssignmentStatus <> 'REJECT'
        AND
        o.writerAssignmentStatus <>'COMPLETED'
        AND
        o.paymentStatus ='PAID'
         )
            """)
List<UserOrdersDetailsEntity> findByWriterId(@Param("id") Long id);

@Query("""
SELECT o FROM UserOrdersDetailsEntity o
WHERE (
o.writerAssignmentStatus IS NULL
 Or 
o.writerAssignmentStatus ='FINDING_WRITER'
 )
AND NOT EXISTS (
    SELECT 1 FROM OrderWriterActionEntity a
    WHERE a.order.id = o.id
    AND a.writer.id = :writerId
    AND a.action = 'REJECT'
)
""")
List<UserOrdersDetailsEntity> findAvailableOrders(@Param("writerId") Long writerId);





   @Query("""
        select o  from UserOrdersDetailsEntity o
            where o.userFirebaseUid =:id
            AND 
            o.writerAssignmentStatus ='REVIEW'
                """)
    List<UserOrdersDetailsEntity> findByFirebaseUidOnlyReview(@Param("id") String  id);



    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""

        SELECT o from UserOrdersDetailsEntity o
        where 
        o.id =:id
        AND
        o.writerAssignmentStatus=:status
            
            """)
    Optional<UserOrdersDetailsEntity> findByIdAndWriterAssignmentStatus(Long id, String status);




    @Query(value = """
            SELECT COUNT(*)
            FROM user_orders_details_entity
            WHERE writer_firebase_uid = :writerFirebaseUid
            AND writer_assignment_status = :status
            """, nativeQuery = true)
    int countWriterOrdersByStatus(
            @Param("writerFirebaseUid") String writerFirebaseUid,
            @Param("status") String status
    );

  @Query(value = """
            SELECT COALESCE(SUM(total_order_amount), 0)
            FROM user_orders_details_entity
            WHERE writer_firebase_uid = :writerFirebaseUid
            AND writer_assignment_status = 'COMPLETED'
            """, nativeQuery = true)
    Double getTotalEarningByWriterFirebaseUid(
            @Param("writerFirebaseUid") String writerFirebaseUid
    );

}
