package com.example.likhwao.controller.ADMIN;

import com.example.likhwao.DTO.ADMIN.AdminRaiseDisputeRequestDto;
import com.example.likhwao.DTO.ADMIN.AdminRaiseDisputeResponse;
import com.example.likhwao.Services.ADMIN.AdminUserDisputeService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user/orders")
public class AdminUserDisputeController {

    private final AdminUserDisputeService userDisputeService;

    public AdminUserDisputeController(AdminUserDisputeService userDisputeService) {
        this.userDisputeService = userDisputeService;
    }

    @PostMapping("/{orderId}/raise-dispute")
    public ResponseEntity<?> raiseDispute(
             @RequestHeader("Authorization") String token ,
            @PathVariable Long orderId,
            @RequestBody AdminRaiseDisputeRequestDto request
    ) {
        try {
             

            AdminRaiseDisputeResponse response = userDisputeService.raiseDispute(
                    orderId,
                    token,
                    request
            );

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("status", "error");
            error.put("message", e.getMessage());

            return ResponseEntity.badRequest().body(error);
        }
    }
}