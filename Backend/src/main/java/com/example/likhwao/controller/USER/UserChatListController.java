package com.example.likhwao.controller.USER;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.DTO.USER.UserChatListDto;
import com.example.likhwao.Services.USER.UserChatListService;

@RestController
@RequestMapping("/api/user_side/chats")
public class UserChatListController {

    @Autowired
    private UserChatListService userChatListService;

    @GetMapping("/writerList")
    public List<UserChatListDto> getChatList(@RequestHeader("Authorization") String token)
    {
        System.out.println("Controller hit hurrayyyy !!! ");
         return  userChatListService.getChatListData(token);

    }
}
