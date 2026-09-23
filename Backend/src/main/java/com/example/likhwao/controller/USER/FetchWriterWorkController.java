package com.example.likhwao.controller.USER;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.DTO.USER.WriterWorkDTO;
import com.example.likhwao.Repository.WRITER.WriterWorkRepository;
import com.example.likhwao.Repository.WRITER.WritersDetailsEntityRepository;
import com.example.likhwao.Services.USER.FetchWriterWorkService;
import com.example.likhwao.Services.WRITER.FetchUserOrderServices;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.storage.Blob;
import com.google.cloud.storage.Bucket;
import com.google.cloud.storage.Storage;
import com.google.firebase.cloud.StorageClient;
import com.google.firebase.cloud.FirestoreClient;


@RestController
@RequestMapping("/api/user_side")
public class FetchWriterWorkController {

    @Autowired
    private FetchWriterWorkService workService;



    @GetMapping("/writerWork")
    public List<WriterWorkDTO> getWriterWork(@RequestHeader("Authorization") String token)
    {
            
       return workService.getWriterWorks(token);
      

    }


    @GetMapping("/{orderId}/writer-file-url")
public ResponseEntity<?> getWriterFileUrlForWriter(
        @RequestHeader("Authorization") String token,
        @PathVariable Long orderId
) {
    try {
        if (token == null || !token.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body("INVALID TOKEN");
        }

        token = token.substring(7);

        FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
        String uid = decoded.getUid();

        if (uid == null) {
            return ResponseEntity.status(401).body("Unauthorized user");
        }

        Firestore db = FirestoreClient.getFirestore();

        var orderDoc = db.collection("orders")
                .document(orderId.toString())
                .get()
                .get();

        if (!orderDoc.exists()) {
            return ResponseEntity.status(404).body("Order not found in Firebase");
        }

        Map<String, Object> orderData = orderDoc.getData();

        if (orderData == null) {
            return ResponseEntity.status(404).body("Order data not found");
        }

        String userFirebaseUid = orderData.get("userFirebaseUid") != null
                ? orderData.get("userFirebaseUid").toString()
                : null;

        String writerFirebaseUid = orderData.get("writerFirebaseUid") != null
                ? orderData.get("writerFirebaseUid").toString()
                : null;

        if (!uid.equals(userFirebaseUid) && !uid.equals(writerFirebaseUid)) {
            return ResponseEntity.status(403).body("Unauthorized for this order");
        }

        String filePath = orderData.get("latestSubmissionFilePath") != null
                ? orderData.get("latestSubmissionFilePath").toString()
                : null;

        if (filePath == null || filePath.isBlank()) {
            return ResponseEntity.status(404).body("Latest submission file path not found");
        }

        Bucket bucket = StorageClient.getInstance()
                .bucket("likhwao-15dcc.firebasestorage.app");

        Blob blob = bucket.get(filePath);

        if (blob == null) {
            return ResponseEntity.status(404).body("File not found in storage: " + filePath);
        }

        URL signedUrl = blob.signUrl(
                15,
                TimeUnit.MINUTES,
                Storage.SignUrlOption.withV4Signature()
        );

        return ResponseEntity.ok(Map.of(
                "url", signedUrl.toString(),
                "filePath", filePath
        ));

    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.status(500).body(e.getMessage());
    }
}


@GetMapping("/{orderId}/writer-file-url-by-path")
public ResponseEntity<?> getWriterFileUrlByPath(
        @RequestHeader("Authorization") String token,
        @PathVariable Long orderId,
        @RequestParam String filePath
) {
    try {
        if (token == null || !token.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body("INVALID TOKEN");
        }

        token = token.substring(7);

        FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
        String uid = decoded.getUid();

        Firestore db = FirestoreClient.getFirestore();

        var orderDoc = db.collection("orders")
                .document(orderId.toString())
                .get()
                .get();

        if (!orderDoc.exists()) {
            return ResponseEntity.status(404).body("Order not found");
        }

        Map<String, Object> orderData = orderDoc.getData();

        String userFirebaseUid = orderData.get("userFirebaseUid") != null
                ? orderData.get("userFirebaseUid").toString()
                : null;

        String writerFirebaseUid = orderData.get("writerFirebaseUid") != null
                ? orderData.get("writerFirebaseUid").toString()
                : null;

        if (!uid.equals(userFirebaseUid) && !uid.equals(writerFirebaseUid)) {
            return ResponseEntity.status(403).body("Unauthorized for this order");
        }

        if (filePath == null || filePath.isBlank()) {
            return ResponseEntity.status(400).body("File path missing");
        }

        Bucket bucket = StorageClient.getInstance()
                .bucket("likhwao-15dcc.firebasestorage.app");

        Blob blob = bucket.get(filePath);

        if (blob == null) {
            return ResponseEntity.status(404).body("File not found in storage");
        }

        URL signedUrl = blob.signUrl(
                15,
                TimeUnit.MINUTES,
                Storage.SignUrlOption.withV4Signature()
        );

        return ResponseEntity.ok(Map.of(
                "url", signedUrl.toString(),
                "filePath", filePath
        ));

    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.status(500).body(e.getMessage());
    }
}
    
}
