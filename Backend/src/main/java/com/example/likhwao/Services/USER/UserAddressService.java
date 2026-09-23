
package com.example.likhwao.Services.USER;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.likhwao.Entity.USER.UserAddressEntity;
import com.example.likhwao.Repository.USER.UserAddressEntityRepository;

@Service
public class UserAddressService {

    @Autowired
    private UserAddressEntityRepository userAddressEntityRepository;

public UserAddressEntity getAddressByUid(String uid) {
    return userAddressEntityRepository.findByUserFirebaseUid(uid);
}


}
