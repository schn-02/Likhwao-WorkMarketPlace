package com.example.likhwao.controller.WRITER;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.Model.UserOrderDetailsModal;
import com.example.likhwao.Services.WRITER.WriterOrderStatusServices;



@RestController
@RequestMapping("/api/writer_side/orders")
public class WriterOrderStatusController {

        @Autowired
        private  WriterOrderStatusServices oes;

    @PostMapping("/writerAssignmentStatus")
    public  void acceptOrder(@RequestHeader("Authorization") String token , @RequestBody UserOrderDetailsModal udm)
    {
        System.out.println("user Firebase uid .." + udm.getUserFirebaseUid());
        System.out.println("writer Firebase uid .." + udm.getWriterFirebaseUid());

      
         oes.orderStatus(token, udm);
        
    }


   
    
}
