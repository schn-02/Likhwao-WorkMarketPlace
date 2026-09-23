
package com.example.likhwao.controller.WRITER;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.DTO.WRITER.WriterChatListDto;
import com.example.likhwao.Services.WRITER.WriterChatListService;

@RestController
@RequestMapping("/api/writer_side/chats")
public class WriterChatListController {

    @Autowired
    private WriterChatListService service;

    @GetMapping("/userList")
    public  List<WriterChatListDto> getUserChatList(@RequestHeader("Authorization") String token){
        
        System.out.println("User chat list api hit hurraayyyyy !!!");
        return service.gWriterChatList(token); 

    } 
}
