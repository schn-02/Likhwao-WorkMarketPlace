package com.example.likhwao.DataLoader;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.example.likhwao.Entity.LikhwaoPricingModal;
import com.example.likhwao.Repository.LikhwaoPricingModalRepository;

@Component
public class DataLoaderPricing  implements CommandLineRunner{

    @Autowired
    public LikhwaoPricingModalRepository likhwaoPricingModalRepository;
    @Override
    public void run(String... args) throws Exception {
        
       if(likhwaoPricingModalRepository.count()==0)
       {
        LikhwaoPricingModal likhwaoPricingModal = new LikhwaoPricingModal();
        likhwaoPricingModal.setDeliveryChargesAmount(100);
        likhwaoPricingModal.setFast_urgency_price(2);
        likhwaoPricingModal.setNormal_urgency_price(1);
        likhwaoPricingModal.setNoteBookChargesAmount(60);
        likhwaoPricingModal.setPerPagePrice(5);
        likhwaoPricingModal.setPlatformfee(10);
        likhwaoPricingModal.setUrgent_urgency_price(3);
        likhwaoPricingModalRepository.save(likhwaoPricingModal);
       }
    }

}
