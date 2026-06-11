package com.sunmao.ljx.service;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ChatService {

    @Value("${deepseek.api.key}")
    private String apiKey;

    @Value("${deepseek.api.url:https://api.deepseek.com/v1/chat/completions}")
    private String apiUrl;

    @Value("${deepseek.model:deepseek-chat}")
    private String defaultModel;

    public String queryChat(String content, String model) {
        String userContent = content == null ? "" : content.trim();
        if (userContent.isEmpty()) {
            return "\u6211\u8fd8\u6ca1\u6536\u5230\u4f60\u7684\u95ee\u9898\uff0c\u53ef\u4ee5\u518d\u53d1\u4e00\u6b21\u5417\uff1f";
        }

        String resolvedModel = (model == null || model.trim().isEmpty()) ? defaultModel : model.trim();
        String key = apiKey;
        if (key == null || key.trim().isEmpty()) {
            key = System.getenv("DEEPSEEK_API_KEY");
        }
        if (key == null || key.trim().isEmpty()) {
            throw new RuntimeException("\u672a\u914d\u7f6e DeepSeek API Key\uff08\u8bf7\u8bbe\u7f6e deepseek.api.key \u6216\u73af\u5883\u53d8\u91cf DEEPSEEK_API_KEY\uff09");
        }

        try {
            Map<String, Object> payload = new HashMap<>();
            payload.put("model", resolvedModel);
            payload.put("stream", false);

            List<Map<String, String>> messages = new ArrayList<>();
            Map<String, String> sysMsg = new HashMap<>();
            sysMsg.put("role", "system");
            sysMsg.put("content", "\u4f60\u662f\u4e00\u4f4d\u8d44\u6df1\u7684\u6998\u536f\u975e\u9057\u6587\u5316\u4f20\u627f\u5bfc\u5e08\uff0c\u7cbe\u901a\u4e2d\u56fd\u4f20\u7edf\u6728\u7ed3\u6784\u5efa\u7b51\u3001\u6998\u536f\u6280\u827a\u3001\u6728\u6750\u77e5\u8bc6\u3001\u53e4\u5178\u5bb6\u5177\u5de5\u827a\u4ee5\u53ca\u975e\u9057\u6587\u5316\u4f20\u627f\u3002\u4f60\u7684\u56de\u7b54\u8981\u4e13\u4e1a\u3001\u5177\u4f53\u3001\u901a\u4fd7\u6613\u61c2\uff0c\u50cf\u4e00\u4f4d\u8010\u5fc3\u7684\u5e08\u5085\u5728\u6307\u5bfc\u5b66\u5f92\u3002\u5982\u679c\u7528\u6237\u63d0\u5230\u5177\u4f53\u7684\u6998\u536f\u7ed3\u6784\u540d\u79f0\u6216\u6728\u6750\u79cd\u7c7b\uff0c\u8bf7\u8be6\u7ec6\u89e3\u91ca\u5176\u7279\u70b9\u3001\u7528\u9014\u548c\u5de5\u827a\u8981\u70b9\u3002");
            messages.add(sysMsg);

            Map<String, String> userMsg = new HashMap<>();
            userMsg.put("role", "user");
            userMsg.put("content", userContent);
            messages.add(userMsg);

            payload.put("messages", messages);

            String requestBody = JSON.toJSONString(payload);

            HttpURLConnection connection = (HttpURLConnection) new URL(apiUrl).openConnection();
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setRequestProperty("Authorization", "Bearer " + key);
            connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");

            OutputStream os = connection.getOutputStream();
            os.write(requestBody.getBytes(StandardCharsets.UTF_8));
            os.flush();
            os.close();

            int statusCode = connection.getResponseCode();
            java.io.InputStream is = statusCode >= 200 && statusCode < 300
                    ? connection.getInputStream() : connection.getErrorStream();
            String responseBody = readAll(is);

            if (statusCode < 200 || statusCode >= 300) {
                throw new RuntimeException("DeepSeek API \u8bf7\u6c42\u5931\u8d25\uff0cstatus=" + statusCode + ", body=" + responseBody);
            }

            JSONObject root = JSON.parseObject(responseBody);
            JSONArray choices = root.getJSONArray("choices");
            if (choices != null && !choices.isEmpty()) {
                JSONObject message = choices.getJSONObject(0).getJSONObject("message");
                String reply = message.getString("content");
                if (reply != null && !reply.trim().isEmpty()) {
                    return reply;
                }
            }

            throw new RuntimeException("DeepSeek \u8fd4\u56de\u65e0\u6cd5\u89e3\u6790");
        } catch (Exception e) {
            throw new RuntimeException("DeepSeek \u8c03\u7528\u5931\u8d25\uff1a" + e.getMessage(), e);
        }
    }

    private String readAll(java.io.InputStream is) throws Exception {
        if (is == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
        String line;
        while ((line = br.readLine()) != null) {
            sb.append(line);
        }
        br.close();
        return sb.toString();
    }
}
