package com.example.likhwao.controller.USER;

import com.example.likhwao.Model.AuthModel;
import com.example.likhwao.Services.USER.UserDetailsServices;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/user_side/auth")
public class SaveUserDetailsController {

    private final UserDetailsServices userDetailsServices;

   
    public SaveUserDetailsController(UserDetailsServices userDetailsServices) {
        this.userDetailsServices = userDetailsServices;
    }

    @PostMapping("/SaveUserDetails")
    public ResponseEntity<?> saveUserDetails(@RequestBody AuthModel dto) {
        try {
            System.out.println("Save user call");
            System.out.println(dto);

            userDetailsServices.saveUser(dto);

            return ResponseEntity.ok(Map.of(
                    "status", true,
                    "message", "User details saved successfully"
            ));

        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "status", false,
                    "message", e.getMessage()
            ));

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of(
                    "status", false,
                    "message", "Something went wrong"
            ));
        }
    }

    @GetMapping("/checkUser")
    public ResponseEntity<?> checkUser(
            @RequestParam String deviceId,
            @RequestParam String firebaseUid
    ) {
        try {
            return ResponseEntity.ok(
                    userDetailsServices.checkUser(deviceId, firebaseUid)
            );

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of(
                    "status", false,
                    "message", "Something went wrong"
            ));
        }
    }

    @GetMapping("/public/canCreateAccount")
    public ResponseEntity<?> canCreateAccount(
            @RequestParam String deviceId,
            @RequestParam String email
    ) {
        try {
            System.out.println("Checking can create account");

            boolean allowed = userDetailsServices.canCreateAccount(deviceId, email);

            return ResponseEntity.ok(Map.of(
                    "allowed", allowed
            ));

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of(
                    "allowed", false,
                    "message", "Something went wrong"
            ));
        }
    }
}