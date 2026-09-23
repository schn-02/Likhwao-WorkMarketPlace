package com.example.likhwao.FirebaseSetup;


import org.springframework.stereotype.Service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;

@Service
public class FirebaseAuthService {


    public FirebaseToken verify(String token)
    {
        try{

            return FirebaseAuth.getInstance().verifyIdToken(token);

        }catch(Exception e)
        {
               throw new RuntimeException("Invalid Firebase Token");
        }
    }
}
