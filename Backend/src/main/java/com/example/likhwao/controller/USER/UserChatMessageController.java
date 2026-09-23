package com.example.likhwao.controller.USER;


import com.example.likhwao.DTO.USER.ChatMessageRequesDTO;
import com.example.likhwao.DTO.USER.ChatMessageResponse;
import com.example.likhwao.Services.ChatService;
import com.example.likhwao.Services.USER.UserChatMessageService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user_side/chats")
public class UserChatMessageController {

    private final UserChatMessageService userChatMessageService;

     @Autowired
    private  ChatService chatService;

    public UserChatMessageController(UserChatMessageService userChatMessageService) {
        this.userChatMessageService = userChatMessageService;
         System.out.println("UserChatMessageController loaded");
    }

    @PostMapping("/sendMessage")
    public ResponseEntity<ChatMessageResponse> sendMessage(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody ChatMessageRequesDTO request
    ) {
        try {
            ChatMessageResponse response =
                    chatService.sendMessage(authorizationHeader, request);

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            return ResponseEntity
                    .badRequest()
                    .body(ChatMessageResponse.failed(e.getMessage()));
        }
    }
}