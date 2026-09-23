package com.example.likhwao.FirebaseSetup;


import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.google.firebase.auth.FirebaseToken;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class FirebaseFilter implements Filter {

    @Autowired
    FirebaseAuthService firebaseAuthService;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse rep = (HttpServletResponse) response;

        String path = req.getRequestURI();

        if (path.contains("/public")) {
            chain.doFilter(request, response);
            return;
        }

        String authHeader = req.getHeader("Authorization");

        System.out.println("REQUEST PATH: " + path);
        System.out.println("METHOD: " + req.getMethod());
        System.out.println("AUTH HEADER: " + authHeader);

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            rep.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            rep.getWriter().write("Token Missing");
            return;
        }

        String token = authHeader.substring(7);

        try {
            FirebaseToken decoded = firebaseAuthService.verify(token);

            System.out.println("FIREBASE UID: " + decoded.getUid());
            System.out.println("FIREBASE EMAIL: " + decoded.getEmail());

            req.setAttribute("uid", decoded.getUid());
            req.setAttribute("email", decoded.getEmail());
            req.setAttribute("emailVerified", decoded.isEmailVerified());

        } catch (Exception e) {
            e.printStackTrace();
            rep.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            rep.getWriter().write("Invalid Token: " + e.getMessage());
            return;
        }

        chain.doFilter(request, response);
    }
}