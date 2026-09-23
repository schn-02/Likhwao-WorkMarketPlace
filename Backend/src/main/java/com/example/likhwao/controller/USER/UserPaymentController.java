package com.example.likhwao.controller.USER;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.Model.PaymentVerificationRequestModal;
import com.example.likhwao.Services.USER.UserPaymentService;

@RestController
@RequestMapping("/api/user_side/orders")
public class UserPaymentController {


     @Autowired
    private UserPaymentService paymentService;

    @PostMapping("/verifyPayment")
    public ResponseEntity<?> verifyPayment(
          @RequestHeader("Authorization") String token ,
            @RequestBody PaymentVerificationRequestModal request) {

                System.out.println("Verify payment called ..");

        paymentService.verifyPayment(request , token);

        return ResponseEntity.ok("PAYMENT VERIFIED");
    }

}
