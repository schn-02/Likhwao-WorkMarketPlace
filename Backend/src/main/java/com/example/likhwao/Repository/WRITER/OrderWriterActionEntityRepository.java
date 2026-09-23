package com.example.likhwao.Repository.WRITER;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Entity.WRITER.OrderWriterActionEntity;
import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;

public interface OrderWriterActionEntityRepository extends JpaRepository<OrderWriterActionEntity ,Long > {

    @Query("""
             
        SELECT o from OrderWriterActionEntity o
        where(
            o.writer.id =:writerId
            and 
            (
            o.action ='ACCEPTED'
            or
             o.action ='IN_PROGRESS'
             )

        )

            """ )
    List<OrderWriterActionEntity> findInProgressOrder(@Param("writerId") Long writerId);

    @Query("""
             
        SELECT o from OrderWriterActionEntity o
        where(
            o.writer.id =:writerId
            and 
           o.action ='COMPLETED'
             )
            """ )
    List<OrderWriterActionEntity> findCompletedOrder(@Param("writerId") Long writerId);

    @Query("""

        SELECt o from OrderWriterActionEntity o
        where (
           o.writer =:writer
           AND
           o.order =:order
    )  
         """)
    Optional<OrderWriterActionEntity> findByWriterAndOrder(@Param("writer") WriterDetailsEntity  writer , @Param("order") UserOrdersDetailsEntity order);
}
