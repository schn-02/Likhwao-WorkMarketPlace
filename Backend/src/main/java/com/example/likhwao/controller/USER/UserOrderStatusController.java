package com.example.likhwao.controller.USER;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.Model.UserOrderDetailsModal;
import com.example.likhwao.Services.USER.UserOrderStatusServices;

@RestController
@RequestMapping("/api/user_side/orders")
public class UserOrderStatusController {

        @Autowired
        private  UserOrderStatusServices oes;

    @PostMapping("/writerAssignmentStatus")
    public  void acceptOrder(@RequestHeader("Authorization") String token , @RequestBody UserOrderDetailsModal udm)
    {
        System.out.println(udm.getId());
        System.out.println(udm.getWriterAssignmentStatus());
        System.out.println(udm.getWriterWorkId());
        System.out.println(udm.getUserRequestChangeDescription());


      
         oes.orderStatus(token, udm);
        
    }


   
    
}