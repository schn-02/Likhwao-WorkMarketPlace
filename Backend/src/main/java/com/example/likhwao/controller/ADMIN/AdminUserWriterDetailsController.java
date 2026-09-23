package com.example.likhwao.controller.ADMIN;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.DTO.ADMIN.AdminUserWriterDetailsDto;
import com.example.likhwao.Services.ADMIN.AdminUserWriterDetailsService;


@RestController
@RequestMapping("/api/admin/details")
public class AdminUserWriterDetailsController {


    @Autowired
    private AdminUserWriterDetailsService aDetailsService;



    @GetMapping("/user-writer")
    public AdminUserWriterDetailsDto fetchDetails( @RequestHeader("Authorization") String token)
    {


      return aDetailsService.fetchDetails(token);


    }

}
