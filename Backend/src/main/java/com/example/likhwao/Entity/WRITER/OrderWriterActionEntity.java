package com.example.likhwao.Entity.WRITER;

import java.time.LocalDateTime;

import com.example.likhwao.Entity.USER.UserDetailsEntity;
import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

@Entity
public class OrderWriterActionEntity {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
     private Long id;


     @ManyToOne
     @JoinColumn(name="writer_id")
     private WriterDetailsEntity writer;// kis writer ne action liya


     @ManyToOne
     @JoinColumn(name = "order_id")
    private UserOrdersDetailsEntity order; // konsa order

    @ManyToOne
    @JoinColumn(name = "user_id") 
    private UserDetailsEntity user; //konsa user

    private String action;

    private LocalDateTime actionTime;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }



    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public LocalDateTime getActionTime() {
        return actionTime;
    }

    public void setActionTime(LocalDateTime actionTime) {
        this.actionTime = actionTime;
    }

    public WriterDetailsEntity getWriter() {
        return writer;
    }

    public void setWriter(WriterDetailsEntity writer) {
        this.writer = writer;
    }

    public UserOrdersDetailsEntity getOrder() {
        return order;
    }

    public void setOrder(UserOrdersDetailsEntity order) {
        this.order = order;
    }

    public UserDetailsEntity getUser() {
        return user;
    }

    public void setUser(UserDetailsEntity user) {
        this.user = user;
    }

    

   
    
}
