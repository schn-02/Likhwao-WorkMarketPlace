package com.example.likhwao.Services.USER;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.likhwao.DTO.USER.WriterWorkDTO;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Entity.WRITER.WriterWorkEntity;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.example.likhwao.Repository.WRITER.WriterWorkRepository;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;

@Service
public class FetchWriterWorkService {

    @Autowired
    private UserOrdersDetailsEntityRepository uDEntityRepository;

    @Autowired WriterWorkRepository workRepository;


    
    public List<WriterWorkDTO> getWriterWorks(String token) {

    List<WriterWorkDTO> result = new ArrayList<>();

    try {
        token = token.substring(7);
        FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
        String uid = decoded.getUid();

        List<UserOrdersDetailsEntity> orders =
                uDEntityRepository.findByFirebaseUidOnlyReview(uid);

        for (UserOrdersDetailsEntity order : orders) {

            List<WriterWorkEntity> works =
                    workRepository.findbyOrderId(order.getId()); 

            for (WriterWorkEntity work : works) {

                WriterWorkDTO dto = new WriterWorkDTO();

                dto.setFileName(work.getFileName());
                dto.setFileUrl(work.getFilePath());
                dto.setFileSize(work.getFileSize());
                dto.setFilePageCount(work.getFilePageCount());
                dto.setCancellationReason(work.getCancellationReason());
                dto.setOrderCompletedAt_Review(work.getOrderCompletedAt_REVIEW());
                dto.setUserOrderid(order.getId());
                dto.setDeliveryAddress(order.getDeliveryAddress());
                dto.setLatitude(order.getLatitude());
                dto.setLongitude(order.getLongitude());
                dto.setOrderCompletedAt(order.getOrderCompletedAt());
                dto.setOrderCreatedAt(order.getOrderCreatedAt());
                dto.setSelectedDate(order.getSelectedDate());
                dto.setOrderStatus(order.getOrderStatus());
                dto.setTypeOfWork(order.getTypeOfWork());
                dto.setWriterAssignmentStatus(order.getWriterAssignmentStatus());
                dto.setTotalOrderAmount(order.getTotalOrderAmount());
                dto.setSelectedDeadLineUrgency(order.getSelectedDeadLineUrgency());
                dto.setUserId(order.getUser().getId());
                dto.setWriterFirebaseUid(order.getWriterFirebaseUid());
                dto.setSelectedInkColor(order.getSelectedInkColor());
                dto.setSelectedNotebook(order.getSelectedNotebook());
                dto.setDeliveryChargesAmount(order.getDeliveryChargesAmount());
                dto.setPlatformFeeAmount(order.getPlatformFeeAmount());
                dto.setNoteBookChargesAmount(order.getNoteBookChargesAmount());
                dto.setRazorpayOrderId(order.getRazorpayOrderId());
                dto.setPaymentId(order.getPaymentId());
                dto.setPaymentBank(order.getPaymentBank());
                dto.setPaymentStatus(order.getPaymentStatus());
                dto.setPaymentMethod(order.getPaymentMethod());
                dto.setRefundId(order.getRefundId());
                dto.setRefundStatus(order.getRefundStatus());
                // dto.setUserFileUrl(order.getFileUrl());
                dto.setUserFileName(order.getFileName());
                dto.setWriterSuggestionText(work.getWriterSuggestionText());

                dto.setUserFilePageCount(order.getFilePageCount());
                dto.setUserFileSize(order.getFileSize());
                dto.setUserSuggestionText(order.getWriterAssignmentStatus());

                dto.setWriterWorkId(work.getWriterWorkId());
                 
               

                result.add(dto); 
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return result;
}
}
