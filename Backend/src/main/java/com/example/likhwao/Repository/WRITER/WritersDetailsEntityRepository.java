package com.example.likhwao.Repository.WRITER;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;
import java.util.List;



public interface WritersDetailsEntityRepository  extends JpaRepository<WriterDetailsEntity , Long>{

    
   Optional<WriterDetailsEntity>  findByFirebaseUid(String firebaseUid);


    Optional<WriterDetailsEntity> findByPhoneNumber(String phoneNumber);

      
    boolean existsByEmail(String email);
        
        boolean existsByFirebaseUid (String firebaseUid);

        Optional<WriterDetailsEntity> findByEmail(String email);
        

}
