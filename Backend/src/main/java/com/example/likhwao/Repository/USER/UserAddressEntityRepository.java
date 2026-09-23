package com.example.likhwao.Repository.USER;



import org.springframework.data.jpa.repository.JpaRepository;

import com.example.likhwao.Entity.USER.UserAddressEntity;


public interface UserAddressEntityRepository  extends JpaRepository<UserAddressEntity ,Long>{


    UserAddressEntity findByUserFirebaseUid(String firebaseUid);


}