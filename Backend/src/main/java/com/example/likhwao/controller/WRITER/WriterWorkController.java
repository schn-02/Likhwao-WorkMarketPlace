package com.example.likhwao.controller.WRITER;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;
import com.example.likhwao.Model.WriterWorkModel;
import com.example.likhwao.Repository.WRITER.WritersDetailsEntityRepository;
import com.example.likhwao.Services.WRITER.WriterWorkService;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;

@RestController
@RequestMapping("/api/writer_side/orders")
public class WriterWorkController {

    @Autowired
    private WriterWorkService workService;

    

    @Autowired
    private WritersDetailsEntityRepository wEntityRepository;



    @PostMapping("/uploadWork")
    public ResponseEntity<Map<String,Object>> uploadDetaiils(@RequestHeader("Authorization") String token ,@RequestBody WriterWorkModel wom){

        return  workService.saveWriterWork(token , wom );
         
        
        
    }


    @PostMapping("/uploadWorkFile/{orderId}")
public ResponseEntity<Map<String, String>> uploadFile(
        @RequestHeader("Authorization") String authHeader,
        @RequestParam("file") MultipartFile file,
        @PathVariable Long orderId
) {
    try {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body(Map.of("error", "Invalid Token"));
        }

        String token = authHeader.substring(7);

        FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
        String uid = decoded.getUid();

        WriterDetailsEntity writer = wEntityRepository.findByFirebaseUid(uid)
                .orElseThrow(() -> new RuntimeException("Writer Not Found"));

        if (!uid.equals(writer.getFirebaseUid())) {
            return ResponseEntity.status(403).body(Map.of("error", "Unauthorized writer"));
        }

        Map<String, String> response =
                workService.uploadWriterFile(file, orderId, authHeader);

        response.put("writerId", writer.getId().toString());

        return ResponseEntity.ok(response);

    } catch (Exception e) {
        return ResponseEntity.status(500).body(
                Map.of("error", e.getMessage())
        );
    }
}

 

}
