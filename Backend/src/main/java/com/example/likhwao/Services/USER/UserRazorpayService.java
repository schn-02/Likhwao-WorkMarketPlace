package com.example.likhwao.Services.USER;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;

@Service
public class UserRazorpayService {

    private RazorpayClient razorpayClient;


 
    @Autowired
    public UserRazorpayService(@Value("${razorpay.key_id}") String keyId,
                           @Value("${razorpay.key_secret}") String keySecret) throws RazorpayException {
        razorpayClient = new RazorpayClient(keyId, keySecret);
    }

    public Order createOrder(int amount) {
        JSONObject orderRequest = new JSONObject();
        orderRequest.put("amount", amount * 100); // paise me
        orderRequest.put("currency", "INR");
        orderRequest.put("payment_capture", 1);
        
        try {
            return razorpayClient.orders.create(orderRequest);
        } catch (RazorpayException e) {
            throw new RuntimeException(e);
        }
    }
}
