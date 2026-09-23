package com.example.likhwao.Services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.likhwao.Entity.LikhwaoPricingModal;
import com.example.likhwao.Repository.LikhwaoPricingModalRepository;

@Service
public class PricingService {

     @Autowired
    private LikhwaoPricingModalRepository pricingRepository;

    public LikhwaoPricingModal getPricing() {
        return pricingRepository.findAll()
                .stream()
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Pricing not found"));
    }

}
