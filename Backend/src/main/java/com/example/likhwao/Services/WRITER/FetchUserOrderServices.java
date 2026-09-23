package com.example.likhwao.Services.WRITER;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.likhwao.DTO.WRITER.FetchUserOrdersDTO;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Entity.WRITER.OrderWriterActionEntity;
import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.example.likhwao.Repository.WRITER.OrderWriterActionEntityRepository;
import com.example.likhwao.Repository.WRITER.WritersDetailsEntityRepository;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;

import jakarta.transaction.Transactional;

@Service
public class FetchUserOrderServices {

  @Autowired
  private WritersDetailsEntityRepository wder;
    @Autowired
    private UserOrdersDetailsEntityRepository uODRepository;


    @Autowired
    private OrderWriterActionEntityRepository owar;

    @Transactional
    public List<FetchUserOrdersDTO> fetchAllOrders(String token)
    {
      try{
               token = token.substring(7);
               FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
               String uid = decoded.getUid();
               WriterDetailsEntity wde = wder.findByFirebaseUid(uid)
                                             .orElseThrow(()-> new RuntimeException("Writer not found"));
                Long writerId =wde.getId();


          System.out.println("Fetching orders ...");
          List<UserOrdersDetailsEntity> orders = uODRepository.findAvailableOrders(writerId);

          return orders.stream().map(o->{

            FetchUserOrdersDTO dto = new FetchUserOrdersDTO();

            dto.setUserOrderid(o.getId());
            dto.setFileName(o.getFileName());
            // dto.setFileUrl(o.getFileUrl());
            dto.setFileSize(o.getFileSize());
            dto.setUserFilePageCount(o.getFilePageCount());
            dto.setTypeOfWork(o.getTypeOfWork());
            dto.setLanguageSelectedChips(o.getLanguageSelectedChips());
            dto.setSelectedInkColor(o.getSelectedInkColor());
            dto.setSelectedNotebook(o.getSelectedNotebook());
            dto.setSelectedDeadLineUrgency(o.getSelectedDeadLineUrgency());
            dto.setDeliveryAddress(o.getDeliveryAddress());
            dto.setWriterSuggestionText(o.getWriterSuggestionText());
            dto.setWriterId(writerId);
            dto.setUserId(o.getUser().getId());
            dto.setDeliveryChargesAmount(o.getDeliveryChargesAmount());
            dto.setCancellationReason(o.getCancellationReason());
            dto.setUserEmail(o.getUser().getEmail());
            dto.setDeliveryPickupOption(o.getDeliveryPickupOption());
            dto.setDeliveryOption(o.getWorkToBeDone());
            dto.setSelectedDate(o.getSelectedDate());
            dto.setLatitude(o.getLatitude());
            dto.setLongitude(o.getLongitude());
            dto.setOrderPageCountAmount(o.getOrderPageCountAmount());
            dto.setUrgencyAmount(o.getUrgencyAmount());
            dto.setPlatformFeeAmount(o.getPlatformFeeAmount());
            dto.setNoteBookChargesAmount(o.getNoteBookChargesAmount());
            dto.setTotalOrderAmount(o.getTotalOrderAmount());
            dto.setOrderStatus(o.getOrderStatus());
            dto.setOrderCreatedAt(o.getOrderCreatedAt());
            dto.setUserFirebaseUid(o.getUserFirebaseUid());
            dto.setWriterFirebaseUid(o.getWriterFirebaseUid());
            dto.setUserName(o.getUserName());
            dto.setUserPhone(o.getUserNumber());
            return dto;
          }).toList();

      }
      catch(Exception e)
      {
        throw new RuntimeException(e);
      }
       

    }

     @Transactional
    public List<FetchUserOrdersDTO> fetchInProgressOrders(String token)
    {
      try{
                token = token.substring(7);
                FirebaseToken deocded = FirebaseAuth.getInstance().verifyIdToken(token);
                String uid = deocded.getUid();
      
            
              WriterDetailsEntity wde = wder.findByFirebaseUid(uid)
                                            .orElseThrow(() -> new RuntimeException("Writer not found "));

              Long writerId = wde.getId(); 
              
              List<OrderWriterActionEntity> actions = owar.findInProgressOrder(writerId);

              List<Long> orderIds = actions.stream().map(a-> a.getOrder().getId()).toList();

              if(orderIds.isEmpty())
              {
                return new ArrayList<>();
              }

              List<UserOrdersDetailsEntity> orders = uODRepository.findAllById(orderIds);

              return orders.stream().map(o->{

                FetchUserOrdersDTO dto = new FetchUserOrdersDTO();
            dto.setUserOrderid(o.getId());
            dto.setFileName(o.getFileName());
            // dto.setFileUrl(o.getFileUrl());
            dto.setFileSize(o.getFileSize());
            dto.setUserFilePageCount(o.getFilePageCount());
            dto.setTypeOfWork(o.getTypeOfWork());
            dto.setLanguageSelectedChips(o.getLanguageSelectedChips());
            dto.setSelectedInkColor(o.getSelectedInkColor());
            dto.setSelectedNotebook(o.getSelectedNotebook());
            dto.setSelectedDeadLineUrgency(o.getSelectedDeadLineUrgency());
            dto.setDeliveryAddress(o.getDeliveryAddress());
            dto.setWriterSuggestionText(o.getWriterSuggestionText());
            dto.setWriterId(writerId);
            dto.setUserId(o.getUser().getId());
            dto.setDeliveryChargesAmount(o.getDeliveryChargesAmount());
            dto.setCancellationReason(o.getCancellationReason());
            dto.setUserEmail(o.getUser().getEmail());
            dto.setUserPhone(o.getUser().getPhoneNumber());
            dto.setUserName(o.getUser().getName());
            dto.setDeliveryPickupOption(o.getDeliveryPickupOption());
            dto.setDeliveryOption(o.getWorkToBeDone());
            dto.setSelectedDate(o.getSelectedDate());
            dto.setLatitude(o.getLatitude());
            dto.setLongitude(o.getLongitude());
            dto.setOrderPageCountAmount(o.getOrderPageCountAmount());
            dto.setUrgencyAmount(o.getUrgencyAmount());
            dto.setPlatformFeeAmount(o.getPlatformFeeAmount());
            dto.setNoteBookChargesAmount(o.getNoteBookChargesAmount());
            dto.setTotalOrderAmount(o.getTotalOrderAmount());
            dto.setOrderStatus(o.getOrderStatus());
            dto.setOrderCreatedAt(o.getOrderCreatedAt());
            dto.setWriterAssignmentStatus(o.getWriterAssignmentStatus());
            dto.setUserFirebaseUid(o.getUserFirebaseUid());
            dto.setWriterFirebaseUid(o.getWriterFirebaseUid());

            return dto;
                   
              }).toList();



          
              

              
      }
    catch(Exception e)
    {
      System.out.println(e);
      throw new RuntimeException(e);
    }
    }


      @Transactional
      public List<FetchUserOrdersDTO> fetchCompletedOrders(String token)
    {
      try{
                token = token.substring(7);
                FirebaseToken deocded = FirebaseAuth.getInstance().verifyIdToken(token);
                String uid = deocded.getUid();
      
            
              WriterDetailsEntity wde = wder.findByFirebaseUid(uid)
                                            .orElseThrow(() -> new RuntimeException("Writer not found "));

              Long writerId = wde.getId(); 
              
              List<OrderWriterActionEntity> actions = owar.findCompletedOrder(writerId);

              List<Long> orderIds = actions.stream().map(a-> a.getOrder().getId()).toList();

              if(orderIds.isEmpty())
              {
                return new ArrayList<>();
              }

              List<UserOrdersDetailsEntity> orders = uODRepository.findAllById(orderIds);

              return orders.stream().map(o->{

                FetchUserOrdersDTO dto = new FetchUserOrdersDTO();
            dto.setUserOrderid(o.getId());
            dto.setFileName(o.getFileName());
            // dto.setFileUrl(o.getFileUrl());
            dto.setFileSize(o.getFileSize());
            dto.setUserFilePageCount(o.getFilePageCount());
            dto.setTypeOfWork(o.getTypeOfWork());
            dto.setLanguageSelectedChips(o.getLanguageSelectedChips());
            dto.setSelectedInkColor(o.getSelectedInkColor());
            dto.setSelectedNotebook(o.getSelectedNotebook());
            dto.setSelectedDeadLineUrgency(o.getSelectedDeadLineUrgency());
            dto.setDeliveryAddress(o.getDeliveryAddress());
            dto.setWriterSuggestionText(o.getWriterSuggestionText());
            dto.setWriterId(writerId);
            dto.setUserId(o.getUser().getId());
            dto.setDeliveryChargesAmount(o.getDeliveryChargesAmount());
            dto.setCancellationReason(o.getCancellationReason());
            dto.setUserEmail(o.getUser().getEmail());
            dto.setUserPhone(o.getUser().getPhoneNumber());
            dto.setUserName(o.getUser().getName());
            dto.setDeliveryPickupOption(o.getDeliveryPickupOption());
            dto.setDeliveryOption(o.getWorkToBeDone());
            dto.setSelectedDate(o.getSelectedDate());
            dto.setLatitude(o.getLatitude());
            dto.setLongitude(o.getLongitude());
            dto.setOrderPageCountAmount(o.getOrderPageCountAmount());
            dto.setUrgencyAmount(o.getUrgencyAmount());
            dto.setPlatformFeeAmount(o.getPlatformFeeAmount());
            dto.setNoteBookChargesAmount(o.getNoteBookChargesAmount());
            dto.setTotalOrderAmount(o.getTotalOrderAmount());
            dto.setOrderStatus(o.getOrderStatus());
            dto.setOrderCreatedAt(o.getOrderCreatedAt());
            dto.setWriterAssignmentStatus(o.getWriterAssignmentStatus());
            dto.setUserFirebaseUid(o.getUserFirebaseUid());
            dto.setWriterFirebaseUid(o.getWriterFirebaseUid());

            return dto;
                   
              }).toList();



          
              

              
      }
    catch(Exception e)
    {
      System.out.println(e);
      throw new RuntimeException(e);
    }
    }

@Transactional
    public FetchUserOrdersDTO fetchOrderbyId(String token , Long orderId)
    {
       
      try{

        if(token == null || !token.startsWith("Bearer ")) {
        throw new RuntimeException("Invalid token");
          }

         token = token.substring(7);

         FirebaseToken user = FirebaseAuth.getInstance().verifyIdToken(token);

         String uid = user.getUid();

          WriterDetailsEntity wde = wder.findByFirebaseUid(uid)
                                            .orElseThrow(() -> new RuntimeException("Writer not found "));

              Long writerId = wde.getId(); 
              


         UserOrdersDetailsEntity o = uODRepository.findById(orderId).orElseThrow(()->
        new RuntimeException("Order Not found "));

         if(o==null)
         {
          return null;
         }

       
          FetchUserOrdersDTO dto = new FetchUserOrdersDTO();
            dto.setUserOrderid(o.getId());
            dto.setFileName(o.getFileName());
            dto.setUserFilePath(o.getUserFilePath());
            dto.setFileSize(o.getFileSize());
            dto.setUserFilePageCount(o.getFilePageCount());
            dto.setTypeOfWork(o.getTypeOfWork());
            dto.setLanguageSelectedChips(o.getLanguageSelectedChips());
            dto.setSelectedInkColor(o.getSelectedInkColor());
            dto.setSelectedNotebook(o.getSelectedNotebook());
            dto.setSelectedDeadLineUrgency(o.getSelectedDeadLineUrgency());
            dto.setDeliveryAddress(o.getDeliveryAddress());
            dto.setWriterSuggestionText(o.getWriterSuggestionText());
            dto.setWriterId(writerId);
            dto.setUserId(o.getUser().getId());
            dto.setDeliveryChargesAmount(o.getDeliveryChargesAmount());
            dto.setCancellationReason(o.getCancellationReason());
            dto.setUserEmail(o.getUser().getEmail());
            dto.setUserPhone(o.getUser().getPhoneNumber());
            dto.setUserName(o.getUser().getName());
            dto.setDeliveryPickupOption(o.getDeliveryPickupOption());
            dto.setDeliveryOption(o.getWorkToBeDone());
            dto.setSelectedDate(o.getSelectedDate());
            dto.setLatitude(o.getLatitude());
            dto.setLongitude(o.getLongitude());
            dto.setOrderPageCountAmount(o.getOrderPageCountAmount());
            dto.setUrgencyAmount(o.getUrgencyAmount());
            dto.setPlatformFeeAmount(o.getPlatformFeeAmount());
            dto.setNoteBookChargesAmount(o.getNoteBookChargesAmount());
            dto.setTotalOrderAmount(o.getTotalOrderAmount());
            dto.setOrderStatus(o.getOrderStatus());
            dto.setOrderCreatedAt(o.getOrderCreatedAt());
            dto.setWriterAssignmentStatus(o.getWriterAssignmentStatus());
            dto.setUserFirebaseUid(o.getUserFirebaseUid());
            dto.setWriterFirebaseUid(o.getWriterFirebaseUid());
            dto.setFullName(o.getUserName());
            dto.setMobileNumber(o.getUserNumber());

            return dto;
            
                                                        

        


      }catch(Exception e)
      {

       throw new RuntimeException(e.getMessage());
        
      }
         

    }



    private FetchUserOrdersDTO mapToFetchUserOrdersDTO(
        UserOrdersDetailsEntity o,
        Long writerId
) {
    FetchUserOrdersDTO dto = new FetchUserOrdersDTO();

    dto.setUserOrderid(o.getId());
    dto.setFileName(o.getFileName());
    dto.setUserFilePath(o.getUserFilePath());
    dto.setFileSize(o.getFileSize());
    dto.setUserFilePageCount(o.getFilePageCount());
    dto.setTypeOfWork(o.getTypeOfWork());
    dto.setLanguageSelectedChips(o.getLanguageSelectedChips());
    dto.setSelectedInkColor(o.getSelectedInkColor());
    dto.setSelectedNotebook(o.getSelectedNotebook());
    dto.setSelectedDeadLineUrgency(o.getSelectedDeadLineUrgency());
    dto.setDeliveryAddress(o.getDeliveryAddress());
    dto.setWriterSuggestionText(o.getWriterSuggestionText());

    dto.setWriterId(writerId);

    if (o.getUser() != null) {
        dto.setUserId(o.getUser().getId());
        dto.setUserEmail(o.getUser().getEmail());
        dto.setUserPhone(o.getUser().getPhoneNumber());
        dto.setUserName(o.getUser().getName());
    }

    dto.setDeliveryChargesAmount(o.getDeliveryChargesAmount());
    dto.setCancellationReason(o.getCancellationReason());
    dto.setDeliveryPickupOption(o.getDeliveryPickupOption());
    dto.setDeliveryOption(o.getWorkToBeDone());
    dto.setSelectedDate(o.getSelectedDate());
    dto.setLatitude(o.getLatitude());
    dto.setLongitude(o.getLongitude());
    dto.setOrderPageCountAmount(o.getOrderPageCountAmount());
    dto.setUrgencyAmount(o.getUrgencyAmount());
    dto.setPlatformFeeAmount(o.getPlatformFeeAmount());
    dto.setNoteBookChargesAmount(o.getNoteBookChargesAmount());
    dto.setTotalOrderAmount(o.getTotalOrderAmount());
    dto.setOrderStatus(o.getOrderStatus());
    dto.setOrderCreatedAt(o.getOrderCreatedAt());
    dto.setWriterAssignmentStatus(o.getWriterAssignmentStatus());
    dto.setUserFirebaseUid(o.getUserFirebaseUid());
    dto.setWriterFirebaseUid(o.getWriterFirebaseUid());

    dto.setFullName(o.getUserName());
    dto.setMobileNumber(o.getUserNumber());

    return dto;


    
}






}
