package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.service.ChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    @Autowired
    private ChatService chatService;

    @PostMapping("/query")
    public Result<Map<String, Object>> query(@RequestParam String content,
                                              @RequestParam(required = false) String model) {
        Map<String, Object> result = new HashMap<>();
        String reply = chatService.queryChat(content, model);
        result.put("reply", reply);
        return Result.success(result);
    }
}
