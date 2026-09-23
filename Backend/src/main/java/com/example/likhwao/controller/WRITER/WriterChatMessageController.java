package com.example.likhwao.controller.WRITER;

import com.example.likhwao.DTO.USER.ChatMessageRequesDTO;
import com.example.likhwao.DTO.USER.ChatMessageResponse;
import com.example.likhwao.Services.ChatService;
import com.example.likhwao.Services.WRITER.WriterChatMessageService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/writer_side/chats")
public class WriterChatMessageController {

    private final WriterChatMessageService writerChatMessageService;

    @Autowired
    private  ChatService chatService;

    public WriterChatMessageController(
            WriterChatMessageService writerChatMessageService
    ) {
        this.writerChatMessageService = writerChatMessageService;
    }

    @PostMapping("/sendMessage")
    public ChatMessageResponse sendMessage(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody ChatMessageRequesDTO request
    ) {
        return chatService.sendMessage(authorizationHeader, request);
    }
}