package com.example.likhwao.FirebaseSetup;

import java.io.FileInputStream;
import java.io.InputStream;

import org.springframework.context.annotation.Configuration;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import jakarta.annotation.PostConstruct;

@Configuration
public class FirebaseConfig {

    @PostConstruct
    public void init() throws Exception {

        String firebaseCredentialsPath = System.getenv("FIREBASE_CREDENTIALS_PATH");

        if (firebaseCredentialsPath == null || firebaseCredentialsPath.isBlank()) {
            throw new IllegalStateException(
                "FIREBASE_CREDENTIALS_PATH environment variable is not set."
            );
        }

        try (InputStream serviceAccount = new FileInputStream(firebaseCredentialsPath)) {

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
            }
        }
    }
}