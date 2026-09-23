package com.example.likhwao.controller.ADMIN;

import com.example.likhwao.DTO.ADMIN.AdminDisputeOrderDetailsResponseDto;
import com.example.likhwao.DTO.ADMIN.AdminDisputeReviseRequestDto;
import com.example.likhwao.Services.ADMIN.AdminDisputeActionService;
import com.example.likhwao.Services.ADMIN.AdminDisputeOrderDetailsService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/disputes")
public class AdminDisputeOrderDetailsController {

    private final AdminDisputeOrderDetailsService adminDisputeOrderDetailsService;

    @Autowired
     private  AdminDisputeActionService adminDisputeActionService;

     
    public AdminDisputeOrderDetailsController(
            AdminDisputeOrderDetailsService adminDisputeOrderDetailsService
    ) {
        this.adminDisputeOrderDetailsService = adminDisputeOrderDetailsService;
    }

    @GetMapping("/{disputeId}/order-details")
    public ResponseEntity<?> getDisputeOrderDetails(
            @PathVariable Long disputeId,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        try {
            AdminDisputeOrderDetailsResponseDto response =
                    adminDisputeOrderDetailsService.getDisputeOrderDetails(
                            disputeId,
                            authorizationHeader
                    );

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("status", "error");
            error.put("message", e.getMessage());

            if (e.getMessage() != null &&
                    e.getMessage().toLowerCase().contains("unauthorized")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
            }

            return ResponseEntity.badRequest().body(error);
        }
    }

 @PostMapping("/{disputesId}/revise")
    public ResponseEntity<?> reviseStatus(
            @RequestHeader("Authorization") String token,
            @PathVariable Long disputesId,
            @RequestBody(required = false) AdminDisputeReviseRequestDto request
    ) {
        try {
            Map<String, Object> response =
                    adminDisputeActionService.changeStatusToRequestChanges(
                            token,
                            disputesId,
                            request
                    );

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            e.printStackTrace();

            return ResponseEntity.badRequest().body(Map.of(
                    "status", "error",
                    "message", e.getMessage()
            ));

        } catch (Exception e) {
            e.printStackTrace();

            return ResponseEntity.internalServerError().body(Map.of(
                    "status", "error",
                    "message", "Unable to request revision"
            ));
        }
    }


    
}
