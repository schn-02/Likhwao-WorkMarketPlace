
package com.example.likhwao.Services.USER;


import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.example.likhwao.Entity.LikhwaoPricingModal;
import com.example.likhwao.Entity.USER.UserAddressEntity;
import com.example.likhwao.Entity.USER.UserDetailsEntity;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Model.UserAddressModal;
import com.example.likhwao.Model.UserOrderDetailsModal;
import com.example.likhwao.Repository.USER.UserAddressEntityRepository;
import com.example.likhwao.Repository.USER.UserDetailsEntityRepository;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.example.likhwao.Services.PricingService;
import com.example.likhwao.controller.USER.OrderResponseControllerHelper;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Bucket;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;
import com.google.firebase.cloud.StorageClient;
import com.razorpay.Order;

import jakarta.transaction.Transactional;


@Service
public class UserOrderService {


    @Autowired
    private UserOrdersDetailsEntityRepository orderRepository;

    @Autowired
    private UserDetailsEntityRepository userDetailsEntityRepository;

    @Autowired
    private UserAddressEntityRepository userAddressEntityRepository;



    @Autowired
    private UserRazorpayService razorpayService;

    @Autowired 
        private PricingService pricingService;

@Transactional
public ResponseEntity<Map<String , Object>> processOrder(UserOrderDetailsModal request , String firebaseUID)
 {

        
    //  Calculate amount (ONLY backend)
    int totalAmount = calculateTotalAmount(request);

    System.out.println("B ");

   
  



    // Create DB order FIRST
    UserOrdersDetailsEntity order = new UserOrdersDetailsEntity();

                
if (request.getAddressList() != null && !request.getAddressList().isEmpty()) {
    UserAddressModal address = request.getAddressList().get(0);

    order.setUserName(address.getFullName());
    order.setUserNumber(address.getMobileNumber());
} else {
    System.out.println("Address list is empty or null");
}

    System.out.println(3);

    order.setFileName(request.getUserFileName());
    order.setFilePageCount(request.getUserFilePageCount());
    order.setFileSize(request.getUserFileSize());
    // order.setFileUrl(request.getFileUrl());
    order.setLanguageSelectedChips(request.getLanguageSelectedChips());
    order.setSelectedInkColor(request.getSelectedInkColor());
    order.setSelectedNotebook(request.getSelectedNotebook());
    order.setWriterSuggestionText(request.getWriterSuggestionText());
    order.setWorkToBeDone(request.getWorkToBeDone());
    order.setDeliveryPickupOption(request.getDeliveryPickupOption());
    order.setSelectedDeadLineUrgency(request.getSelectedDeadLineUrgency());
    order.setSelectedDate(request.getSelectedDate());

    order.setOrderPageCountAmount(request.getOrderPageCountAmount());
    order.setUrgencyAmount(request.getUrgencyAmount());
    order.setDeliveryChargesAmount(request.getDeliveryChargesAmount());
    order.setPlatformFeeAmount(request.getPlatformFeeAmount());
    order.setNoteBookChargesAmount(request.getNoteBookChargesAmount());
    order.setTypeOfWork(request.getTypeOfWork());

    order.setTotalOrderAmount(totalAmount);
    order.setUserFirebaseUid(firebaseUID);
   
    // order.setUserName(request.getUserName());
    // order.setUserNumber(request.getUserNumber());
    order.setWriterAssignmentStatus(request.getWriterAssignmentStatus());
    


              System.out.println("1");


              UserDetailsEntity user = userDetailsEntityRepository.
              findByFirebaseUid(firebaseUID)
              .orElseThrow(() -> new RuntimeException("User not found"));

              order.setUser(user);


          

 if (request.getAddressList() == null || request.getAddressList().isEmpty()) 
    {
    throw new RuntimeException("Address required");
       } 

    UserAddressModal modal = request.getAddressList().get(0);

    order.setDeliveryAddress( modal.getHouseNo() + ", " +
    modal.getLocality() + ", " +
    modal.getCity() + ", " +
    modal.getState() + " - " +
    modal.getPincode());


     UserAddressEntity useraddress = new UserAddressEntity();



    useraddress.setCity(request.getAddressList().get(0).getCity());
    useraddress.setFullName(request.getAddressList().get(0).getFullName());
    useraddress.setHouseNo(request.getAddressList().get(0).getHouseNo());
    useraddress.setLocality(request.getAddressList().get(0).getLocality());
    useraddress.setMobileNumber(request.getAddressList().get(0).getMobileNumber());
    useraddress.setPincode(request.getAddressList().get(0).getPincode());
    useraddress.setSaveAs(request.getAddressList().get(0).getSaveAs());
    useraddress.setState(request.getAddressList().get(0).getState());
    useraddress.setUser(user);



    userAddressEntityRepository.save(useraddress);

    //  Save DB order FIRST
    orderRepository.save(order);

        System.out.println("5");


    Map<String , Object> response = new HashMap<>();
    response.put("orderId", order.getId());
    response.put("status", order.getWriterAssignmentStatus());

    saveIntoFirebase(order);

    return ResponseEntity.ok(response);
   }



   public void deleteOrder(String token , Long orderId)
   {

    try{

        

        if (token != null) {
    token = token.substring(7);
} else {
    throw new RuntimeException("Invalid token");
}
    
    FirebaseToken user = FirebaseAuth.getInstance().verifyIdToken(token);

    String uid = user.getUid();

    
      
       UserOrdersDetailsEntity orders = orderRepository.findById(orderId)
                                                  .orElseThrow(()-> new RuntimeException("Order not found "));

         if (!orders.getUserFirebaseUid().equals(uid)) {
            throw new RuntimeException("Unauthorized");
        }

       orders.setWriterAssignmentStatus("CANCELLED");
       orderRepository.save(orders);

       saveIntoFirebase(orders);


    }catch(Exception e)
    {
       System.out.println(e);
    }

   }


   public void saveIntoFirebase(UserOrdersDetailsEntity orders)
   {

    List writerSubmission = new ArrayList<>();

            
    try{

    
    Firestore db =  FirestoreClient.getFirestore();
    Map<String , Object> map = new HashMap<>();
    map.put("status", orders.getWriterAssignmentStatus());
    map.put("writerId", null);
    map.put("writerName", null);
    map.put("InkColor" , orders.getSelectedInkColor());
    map.put("NotebookType", orders.getSelectedNotebook());
    map.put("WriterSuggestionText" , orders.getWriterSuggestionText());
    map.put("userId", orders.getUser().getId());
    map.put("createdAt", orders.getOrderCreatedAt().toString());
    map.put("typeOfWork" , orders.getTypeOfWork());
    map.put("userFilePath" , orders.getUserFilePath());
    map.put("filePageCount", orders.getFilePageCount());
    map.put("totalOrderAmount", orders.getTotalOrderAmount());
    map.put("orderId", orders.getId());
    map.put("selectedLanguage", orders.getLanguageSelectedChips());
    map.put("deadline", orders.getSelectedDate().toString());
    map.put("writerFirebaseUid", null);
    map.put("userFirebaseUid", orders.getUserFirebaseUid());
    map.put("writerSubmission", writerSubmission);
    map.put("urgency", orders.getSelectedDeadLineUrgency());



    // File / order UI
map.put("orderTitle", orders.getTypeOfWork() + " • " + orders.getFilePageCount() + " Pages");
map.put("userFileName", orders.getFileName());
map.put("userFileSize", orders.getFileSize());
map.put("userFilePageCount", orders.getFilePageCount());

// Status / filtering
map.put("statusLabel", getStatusLabel(orders.getWriterAssignmentStatus()));
map.put("hasWriter", false);
map.put("hasWriterSubmission", false);
map.put("latestSubmissionVersion", 0);
map.put("latestWriterWorkId", null);
map.put("latestSubmissionStatus", null);

// Pricing UI
map.put("orderPageCountAmount", orders.getOrderPageCountAmount());
map.put("platformFeeAmount", orders.getPlatformFeeAmount());
map.put("noteBookChargesAmount", orders.getNoteBookChargesAmount());
map.put("deliveryChargesAmount", orders.getDeliveryChargesAmount());
map.put("urgencyAmount", orders.getUrgencyAmount());

// Work details UI
map.put("workToBeDone", orders.getWorkToBeDone());
map.put("deliveryPickupOption", orders.getDeliveryPickupOption());

// Time
map.put("createdAtTimestamp", Timestamp.now());
map.put("updatedAtTimestamp", Timestamp.now());
map.put("statusUpdatedAtTimestamp", Timestamp.now());




    db.collection("orders")
    .document(orders.getId().toString())
    .set(map);

    }catch(Exception e)
    {
         e.printStackTrace();
   throw new RuntimeException("Delete failed");
    }


   }


    private int calculateTotalAmount(UserOrderDetailsModal request) {
        


        try{

        
System.out.println("Compelte 1 !!");


        LikhwaoPricingModal pricingModal = pricingService.getPricing();

        

        
        // Example: Page charges
        int total = request.getUserFilePageCount() * pricingModal.getPerPagePrice(); // ₹5 per page
System.out.println("Compelte 3 !!");
        // Urgency charges
        if("NORMAL".equalsIgnoreCase(request.getSelectedDeadLineUrgency())) total *= pricingModal.getNormal_urgency_price();

        // Delivery charges
        if("FAST".equalsIgnoreCase(request.getSelectedDeadLineUrgency())) total *= pricingModal.getFast_urgency_price();

        if("URGENT".equalsIgnoreCase(request.getSelectedDeadLineUrgency())) total *= pricingModal.getUrgent_urgency_price();

        if("Company_Notebook".equalsIgnoreCase(request.getWorkToBeDone())) total += pricingModal.getNoteBookChargesAmount();

        if("Self_Delivery".equalsIgnoreCase(request.getDeliveryPickupOption())) 
            {
                total += 0;
            }

            if("Required_Delivery".equalsIgnoreCase(request.getDeliveryPickupOption())) 
            {
                total += pricingModal.getDeliveryChargesAmount();
            }

            System.out.println("Compelte 4 !!");

            
        
         


        // Platform fee
        total += pricingModal.getPlatformfee();
        
        System.out.println("Compelte !!");

        return total;
        }catch(Exception e)
        {
            e.printStackTrace();
            throw new RuntimeException(e.getMessage());
        }
    }



    @Transactional
    public OrderResponseControllerHelper createPayment(String token , Long orderId)
    {

        try{

        
        
        if(token!=null && !token.startsWith("Bearer "))
        {
            throw new RuntimeException("Unauthorized or Token is null !! ");
        }

          token = token.substring(7);

        FirebaseToken decode = FirebaseAuth.getInstance().verifyIdToken(token);
        String uid = decode.getUid();





         
       
        

         UserOrdersDetailsEntity order = orderRepository.findById(orderId).orElseThrow(()->
        new RuntimeException("Order not found"));

      UserOrderDetailsModal request = new UserOrderDetailsModal();

         request.setUserFilePageCount(order.getFilePageCount());
         request.setSelectedDeadLineUrgency(order.getSelectedDeadLineUrgency());
         request.setWorkToBeDone(order.getWorkToBeDone());
         request.setDeliveryPickupOption(order.getDeliveryPickupOption());
         request.setDeliveryChargesAmount(order.getDeliveryChargesAmount());
         String userUid = order.getUserFirebaseUid();

         if(!userUid.equals(uid))
         {
            throw new RuntimeException("Unauthorized");
         }

         int totalAmount = calculateTotalAmount(request);



        Order rajorpayOrder = razorpayService.createOrder(totalAmount);
        order.setRazorpayOrderId(rajorpayOrder.get("id").toString());
        orderRepository.save(order);

        //Response to flutter
        OrderResponseControllerHelper response  = new OrderResponseControllerHelper();
        response.setAmount(totalAmount);
        response.setRazorpayOrderId(rajorpayOrder.get("id").toString());
        response.setCurrency("INR");
    
        

        return response;
    }catch(Exception e)
    {

        throw new RuntimeException("Something went wrong !! " + e);
    }

    }


    public Map<String , String> uploadUserFile(MultipartFile file , Long orderId)
    {
        try{

             String originalFileName = file.getOriginalFilename();
             if (originalFileName == null || originalFileName.isBlank()) {
            originalFileName = "requirement_file";
        }
             String safeFileName = originalFileName.replaceAll("\\s+", "_");

             String filePath ="orders/"+ orderId+ "/user/" + System.currentTimeMillis() + "_" +safeFileName;

             Bucket bucket = StorageClient.getInstance().bucket("likhwao-15dcc.firebasestorage.app");
             BlobInfo blobInfo = BlobInfo.newBuilder(bucket.getName(), filePath)
              .setContentType(file.getContentType())
              .build();

            

             bucket.getStorage().create(blobInfo, file.getBytes());


             Map<String , String> response = new HashMap<>();
             response.put("filePath", filePath);
             
             return response;

        }catch(Exception e)
        { 
            throw new RuntimeException("File upload failed: " + e.getMessage());

            
        }
    }

    private String getStatusLabel(String status) {
    if (status == null) {
        return "Unknown";
    }

    switch (status) {
        case "FINDING_WRITER":
            return "Finding Writer";

        case "ACCEPTED":
            return "Accepted";

        case "IN_PROGRESS":
            return "In Progress";

        case "REVIEW":
            return "Under Review";

        case "REQUEST_CHANGES":
            return "Changes Requested";

        case "COMPLETED":
            return "Completed";

        case "CANCELLED":
            return "Cancelled";

        default:
            return status.replace("_", " ");
    }
}
}
