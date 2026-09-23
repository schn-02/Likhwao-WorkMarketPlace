package com.example.likhwao.Entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class LikhwaoPricingModal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private int normal_urgency_price;

    private int fast_urgency_price;

    private int urgent_urgency_price;

    private int platformfee;

    private int perPagePrice;

    private int deliveryChargesAmount;

    private int noteBookChargesAmount;


      private boolean active;


      public Long getId() {
          return id;
      }


      public void setId(Long id) {
          this.id = id;
      }


      public int getNormal_urgency_price() {
          return normal_urgency_price;
      }


      public void setNormal_urgency_price(int normal_urgency_price) {
          this.normal_urgency_price = normal_urgency_price;
      }


      public int getFast_urgency_price() {
          return fast_urgency_price;
      }


      public void setFast_urgency_price(int fast_urgency_price) {
          this.fast_urgency_price = fast_urgency_price;
      }


      public int getUrgent_urgency_price() {
          return urgent_urgency_price;
      }


      public void setUrgent_urgency_price(int urgent_urgency_price) {
          this.urgent_urgency_price = urgent_urgency_price;
      }


      public int getPlatformfee() {
          return platformfee;
      }


      public void setPlatformfee(int platformfee) {
          this.platformfee = platformfee;
      }


      public int getPerPagePrice() {
          return perPagePrice;
      }


      public void setPerPagePrice(int perPagePrice) {
          this.perPagePrice = perPagePrice;
      }


      public int getDeliveryChargesAmount() {
          return deliveryChargesAmount;
      }


      public void setDeliveryChargesAmount(int deliveryChargesAmount) {
          this.deliveryChargesAmount = deliveryChargesAmount;
      }


      public int getNoteBookChargesAmount() {
          return noteBookChargesAmount;
      }


      public void setNoteBookChargesAmount(int noteBookChargesAmount) {
          this.noteBookChargesAmount = noteBookChargesAmount;
      }


      public boolean isActive() {
          return active;
      }


      public void setActive(boolean active) {
          this.active = active;
      }


      public LikhwaoPricingModal() {
      }


      @Override
      public String toString() {
        return "LikhwaoPriceModal [id=" + id + ", normal_urgency_price=" + normal_urgency_price
                + ", fast_urgency_price=" + fast_urgency_price + ", urgent_urgency_price=" + urgent_urgency_price
                + ", platformfee=" + platformfee + ", perPagePrice=" + perPagePrice + ", deliveryChargesAmount="
                + deliveryChargesAmount + ", noteBookChargesAmount=" + noteBookChargesAmount + ", active=" + active
                + "]";
      }




}
