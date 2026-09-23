package com.example.likhwao.controller.WRITER;

import java.net.URL;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.DTO.WRITER.FetchUserOrdersDTO;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.example.likhwao.Repository.WRITER.WritersDetailsEntityRepository;
import com.example.likhwao.Services.WRITER.FetchUserOrderServices;
import com.google.cloud.storage.Blob;
import com.google.cloud.storage.Bucket;
import com.google.cloud.storage.Storage;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.StorageClient;

@RestController
@RequestMapping("api/writer_side/orders")
public class FetchUserOrderController {

    @Autowired
    private FetchUserOrderServices fetchUserOrderServices;

    @Autowired
    private WritersDetailsEntityRepository wder;

    @Autowired
    private UserOrdersDetailsEntityRepository uder;

    @GetMapping("/available")
    public List<FetchUserOrdersDTO> fetchOrders(@RequestHeader("Authorization") String token)
    {
        
      
          return fetchUserOrderServices.fetchAllOrders(token);
    }

    @GetMapping("/inProgress")
    public List<FetchUserOrdersDTO> fetchInProgressOrder(@RequestHeader("Authorization") String token)
    {
        System.out.println("In progress api hit ");
        return fetchUserOrderServices.fetchInProgressOrders(token);
    }


    
    @GetMapping("/Completed")
    public List<FetchUserOrdersDTO> fetchAvailableOrder(@RequestHeader("Authorization") String token)
    {
        System.out.println("In progress api hit ");
       

        return fetchUserOrderServices.fetchCompletedOrders(token);
    }


    @GetMapping("/findById")
    public FetchUserOrdersDTO fetchOrderById(@RequestHeader("Authorization") String token , @RequestParam  Long orderId)
    {

         
        System.out.println("Hit fetch order by id ....!!");

          return fetchUserOrderServices.fetchOrderbyId(token , orderId);
    }


    @GetMapping("/{orderId}/user-file-url")
    public ResponseEntity<?> getUserFileUrlForWriter(@RequestHeader("Authorization") String token , @PathVariable Long orderId)
    {

        try{

            if(token==null || !token.startsWith("Bearer "))
            {
                return ResponseEntity.status(401).body("INVALID TOKEN");
                
            }

            token = token.substring(7);
            FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
            String uid = decoded.getUid();

            if(uid ==null)
            {
                return ResponseEntity.status(404).body("Unauthorized Error");
            }


            UserOrdersDetailsEntity order = uder.findById(orderId).orElseThrow(()->new RuntimeException("Order not found !!"));

            if(order.getUserFilePath()==null ||order.getUserFilePath().isBlank())
            {
                return ResponseEntity.status(404).body("User file not found !");

            }
        
            Bucket bucket = StorageClient.getInstance().bucket("likhwao-15dcc.firebasestorage.app");

            Blob blob = bucket.get(order.getUserFilePath());

            if (blob==null) {
                
                return ResponseEntity.status(404).body("File not found in storage !!");
            }

            URL signedUrl = blob.signUrl(15 , TimeUnit.MINUTES , Storage.SignUrlOption.withV4Signature());

            return ResponseEntity.ok(Map.of("url" , signedUrl.toString()));





        }catch(Exception  e)
        {
             return ResponseEntity.status(500).body(e.getMessage());
        }

    }
}
