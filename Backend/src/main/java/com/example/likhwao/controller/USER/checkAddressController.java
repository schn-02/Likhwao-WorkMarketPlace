
package com.example.likhwao.controller.USER;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.Entity.USER.UserAddressEntity;
import com.example.likhwao.Services.USER.UserAddressService;

@RestController
@RequestMapping("/api/user_side")
public class checkAddressController {


 @Autowired
 private UserAddressService userAddressService;


    @GetMapping("/checkAddress")
public UserAddressEntity getUserAddress(@RequestParam String uid) {
    return userAddressService.getAddressByUid(uid);
}


}
