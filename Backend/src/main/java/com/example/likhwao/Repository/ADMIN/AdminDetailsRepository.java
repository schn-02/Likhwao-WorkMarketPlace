package com.example.likhwao.Repository.ADMIN;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.likhwao.Entity.ADMIN.AdminDetailsEntity;

@Repository
public interface AdminDetailsRepository  extends JpaRepository<AdminDetailsEntity , Long>{

   boolean existsByEmail(String email);

    Optional<AdminDetailsEntity> findByEmail(String email);

    Optional<AdminDetailsEntity> findByFirebaseUid(String firebaseUid);

    
}
