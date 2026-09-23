package com.example.likhwao.Services.ADMIN;

import com.google.cloud.storage.Blob;
import com.google.cloud.storage.Bucket;
import com.google.cloud.storage.Storage;
import com.google.firebase.cloud.StorageClient;
import org.springframework.stereotype.Service;

import java.net.URL;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Service
public class AdminStorageSignedUrlService {

    private static final String BUCKET_NAME = "likhwao-15dcc.firebasestorage.app";

    public Map<String, String> generateSignedUrl(String filePath) throws Exception {
        if (filePath == null || filePath.isBlank()) {
            throw new IllegalArgumentException("File path missing");
        }

        Bucket bucket = StorageClient.getInstance().bucket(BUCKET_NAME);

        Blob blob = bucket.get(filePath);

        if (blob == null) {
            throw new IllegalArgumentException("File not found in storage: " + filePath);
        }

        URL signedUrl = blob.signUrl(
                15,
                TimeUnit.MINUTES,
                Storage.SignUrlOption.withV4Signature()
        );

        return Map.of(
                "url", signedUrl.toString(),
                "filePath", filePath
        );
    }
}