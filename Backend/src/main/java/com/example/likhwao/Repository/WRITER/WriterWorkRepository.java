package com.example.likhwao.Repository.WRITER;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.likhwao.Entity.WRITER.WriterWorkEntity;



public interface WriterWorkRepository  extends JpaRepository< WriterWorkEntity , Long> {



    @Query("""
            select o from WriterWorkEntity o
            where o.user.id =:id
            AND
            o.writerAssignmentStatus ='REVIEW'

            """)
    List<WriterWorkEntity> findByUserId(@Param("id") Long id);


    @Query("""
            
        select w from WriterWorkEntity w
              where w.userOrder.id=:orderId
            """)
    List<WriterWorkEntity> findbyOrderId(Long orderId);


    @Query("""
            select w from WriterWorkEntity w
             where
             w.writerWorkId =:writerWorkId
             AND
             w.userOrder.id =:orderId

            """)
    WriterWorkEntity findbyOrderIdAndWriterWorkId(@Param("writerWorkId") Long writerWorkId ,@Param("orderId") Long orderId);

    @Query("""
                    
        Select w from WriterWorkEntity w
        where 
        w.userOrder.id = :orderId
                    """)
    Optional<WriterWorkEntity> findByOrderId(Long orderId);
}
