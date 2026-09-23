package com.example.likhwao.controller.WRITER;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.DTO.WRITER.HomeStatsResponse;
import com.example.likhwao.Services.WRITER.HomeStatsDataService;

@RestController
@RequestMapping("/api/writer_side")
public class HomeStatsDataController {

    @Autowired
    private HomeStatsDataService homeStatsDataService;

    @GetMapping("/home/stats")
    public ResponseEntity<HomeStatsResponse> getHomeStats(
            @RequestHeader("Authorization") String token
    ) {
        HomeStatsResponse response = homeStatsDataService.getStats(token);
        return ResponseEntity.ok(response);
    }
}