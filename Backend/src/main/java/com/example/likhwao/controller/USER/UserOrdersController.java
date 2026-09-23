package com.example.likhwao.controller.USER;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Model.UserOrderDetailsModal;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.example.likhwao.Services.USER.UserOrderService;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.SetOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;

import jakarta.servlet.http.HttpServletRequest;


@RestController
@RequestMapping("/api/user_side/orders")
public class UserOrdersController {

@Autowired
    private UserOrderService orderService;

    @Autowired
    private UserOrdersDetailsEntityRepository orderRepository;

    
    

     @PostMapping("/create")
    public ResponseEntity<Map<String, Object>>  createOrder(@RequestBody UserOrderDetailsModal orderRequest , HttpServletRequest httpRequest)
    {
        System.out.println("File page count " + orderRequest.getUserFilePageCount());

        System.out.println("CALLED RAJORPAY :- " +orderRequest);

                String firebaseUid = (String) httpRequest.getAttribute("uid");

                 if (firebaseUid == null) {
            throw new RuntimeException("Firebase UID not found in request");
        }

           System.out.println("API hit create 2 !!");


          return orderService.processOrder(orderRequest ,firebaseUid);

    }


    @PostMapping("/delete")
    public void deleteOrder(@RequestHeader("Authorization") String token , @RequestParam Long orderId)
    {

        System.out.println("Delete method call ");
        orderService.deleteOrder(token , orderId);
    }

    @PostMapping("/uploadFile/{orderId}")
public ResponseEntity<?> uploadFile(
        @RequestHeader("Authorization") String authHeader,
        @RequestParam("file") MultipartFile file,
        @PathVariable Long orderId
) {
    try {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body("Invalid Token");
        }

        String idToken = authHeader.substring(7);

        FirebaseToken decodedToken = FirebaseAuth.getInstance()
                .verifyIdToken(idToken);

        String uid = decodedToken.getUid();

        UserOrdersDetailsEntity order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        if (!uid.equals(order.getUserFirebaseUid())) {
            return ResponseEntity.status(403).body("Unauthorized user");
        }

        Map<String, String> fileData = orderService.uploadUserFile(file, orderId);

        Firestore db = FirestoreClient.getFirestore();

        Map<String , Object> map = new HashMap<>();

        map.put("userFilePath", fileData.get("filePath"));

        db.collection("orders")
        .document(orderId.toString()).set(map , SetOptions.merge()).get();

        order.setUserFilePath(fileData.get("filePath"));

        

        orderRepository.save(order);

        return ResponseEntity.ok(fileData);

    } catch (Exception e) {
        return ResponseEntity.status(500).body(e.getMessage());
    }
}


    @PostMapping("/createPayment")
    public OrderResponseControllerHelper createPayment(@RequestHeader("Authorization") String token,Long orderId) {

        try{  
        return orderService.createPayment( token ,orderId);
        }catch(Exception e)
        {
             throw new RuntimeException("Order Error");
        }
    }
    

}


