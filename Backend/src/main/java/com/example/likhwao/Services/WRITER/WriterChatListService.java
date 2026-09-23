package com.example.likhwao.Services.WRITER;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.likhwao.DTO.WRITER.WriterChatListDto;
import com.example.likhwao.Entity.USER.UserDetailsEntity;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.example.likhwao.Repository.WRITER.WritersDetailsEntityRepository;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;

import jakarta.transaction.Transactional;

@Service
public class WriterChatListService {

    @Autowired
    private WritersDetailsEntityRepository wder;

    @Autowired
    private UserOrdersDetailsEntityRepository uoder;


    @Transactional
    public List<WriterChatListDto> gWriterChatList(String token) {
        try {

            if (token == null || !token.startsWith("Bearer ")) {
                System.out.println("Invalid token format");
                return new ArrayList<>();
            }

            token = token.substring(7);

            FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
            String uid = decoded.getUid();

            System.out.println("Firebase UID: " + uid);

            WriterDetailsEntity writer = wder.findByFirebaseUid(uid)
                    .orElseThrow(() -> new RuntimeException("Writer not found with firebase uid: " + uid));

            System.out.println("Writer ID: " + writer.getId());
            System.out.println("Writer Name: " + writer.getName());

            List<UserOrdersDetailsEntity> ordersList = uoder.findByWriterId(writer.getId());

            System.out.println("Total orders found for writer: " + ordersList.size());

            List<WriterChatListDto> finalList = new ArrayList<>();

            for (UserOrdersDetailsEntity orders : ordersList) {

                System.out.println("------------------------------------");
                System.out.println("Order ID: " + orders.getId());
                System.out.println("Order Status: " + orders.getWriterAssignmentStatus());
              
                UserDetailsEntity user = orders.getUser();

                if (user == null) {
                    System.out.println("User is NULL for order id: " + orders.getId());
                    continue;
                }

                System.out.println("User ID: " + user.getId());
                System.out.println("User Name: " + user.getName());
                System.out.println("User Firebase UID: " + user.getFirebaseUid());
                System.out.println("User Phone: " + user.getPhoneNumber());

                WriterChatListDto dto = new WriterChatListDto();

                dto.setUserId(user.getId());
                dto.setOrderId(orders.getId());
                dto.setCountryCode(user.getCountryCode());
                dto.setCountryName(user.getCountryName());
                dto.setCreatedAt(user.getCreatedAt());
                dto.setTotalOrders(user.getTotalOrders());
                dto.setUserNumber(user.getPhoneNumber());
                dto.setWriterId(writer.getId());
                dto.setUserFirebaseUid(user.getFirebaseUid());
                dto.setUserName(user.getName());
                dto.setOrderStatus(orders.getWriterAssignmentStatus());

                finalList.add(dto);
            }

            System.out.println("Final DTO list size: " + finalList.size());
            System.out.println("=========== WRITER CHAT LIST API END ===========");

            return finalList;

        } catch (Exception e) {
            System.out.println("Writer chat list API error: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
}