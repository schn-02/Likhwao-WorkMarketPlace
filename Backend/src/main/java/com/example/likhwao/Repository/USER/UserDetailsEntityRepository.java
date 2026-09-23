package com.example.likhwao.Repository.USER;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;


import com.example.likhwao.Entity.USER.UserDetailsEntity;



public interface UserDetailsEntityRepository extends JpaRepository<UserDetailsEntity , Long> {


   Optional<UserDetailsEntity>  findByFirebaseUid(String firebaseUid);

        boolean existsByFirebaseUid (String firebaseUid);

        Optional<UserDetailsEntity> findByEmail(String email);

         Optional<UserDetailsEntity> findByPhoneNumber(String phoneNumber);


     
}
