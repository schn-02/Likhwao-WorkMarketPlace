package com.example.likhwao.controller.ADMIN;


import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.likhwao.DTO.ADMIN.AdminOrderDetailsResponseDto;
import com.example.likhwao.Services.ADMIN.AdminOrderDetailsService;

@RestController
@RequestMapping("/api/admin")
public class AdminOrderDetailsController {

    private final AdminOrderDetailsService adminOrderDetailsService;

    public AdminOrderDetailsController(AdminOrderDetailsService adminOrderDetailsService) {
        this.adminOrderDetailsService = adminOrderDetailsService;
    }

    @GetMapping("/orders/{orderId}/details")
    public ResponseEntity<?> getOrderDetails(
            @PathVariable Long orderId,
            @RequestHeader("Authorization") String authorizationHeader
    ) {
        try {
            AdminOrderDetailsResponseDto response = adminOrderDetailsService
                    .getOrderDetails(orderId, authorizationHeader);

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(
                    new ErrorResponse(e.getMessage())
            );
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(
                    new ErrorResponse("Something went wrong")
            );
        }
    }

    record ErrorResponse(String message) {}
}