package com.example.likhwao.Services.USER;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.likhwao.DTO.USER.UserChatListDto;
import com.example.likhwao.Entity.USER.UserDetailsEntity;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;
import com.example.likhwao.Repository.USER.UserDetailsEntityRepository;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;

import jakarta.transaction.Transactional;

@Service
public class UserChatListService {

    @Autowired
    private UserOrdersDetailsEntityRepository uoder;

    @Autowired
    private UserDetailsEntityRepository uder;





    @Transactional
    public List<UserChatListDto> getChatListData(String token)
    {
         
        try{

        
        token = token.substring(7);
        FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
        String uid = decoded.getUid();

        UserDetailsEntity user  = uder.findByFirebaseUid(uid)
                                               .orElseThrow();

        List<UserOrdersDetailsEntity> orders = uoder.findByUserId(user.getId());

        return orders.stream().map(order ->{

            WriterDetailsEntity writer = order.getWriter();

            if(writer == null){
               return null;
                }
            UserChatListDto dto = new UserChatListDto();

            dto.setUserId(user.getId());
            dto.setOrderId(order.getId());
            dto.setCountryCode(writer.getCountryCode());
            dto.setCountryName(writer.getCountryName());
            dto.setCreatedAt(writer.getCreatedAt());
            dto.setTotalOrders(writer.getTotalOrders());
            dto.setWriterNumber(writer.getPhoneNumber());
            dto.setWriterId(writer.getId());
            dto.setWriterFirebaseUid(writer.getFirebaseUid());
            dto.setWriterName(writer.getName());
            dto.setOrderStatus(order.getWriterAssignmentStatus());

            return dto;
        }).toList();
                                                                                          





        }
        catch(Exception e)
        {
          System.out.println(e);

            return new ArrayList<>();
        }
         
    }

}
