package com.example.likhwao.Services.WRITER;




import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.likhwao.Entity.USER.UserOrdersDetailsEntity;
import com.example.likhwao.Entity.WRITER.OrderWriterActionEntity;
import com.example.likhwao.Entity.WRITER.WriterDetailsEntity;
import com.example.likhwao.Entity.WRITER.WriterWorkEntity;
import com.example.likhwao.Model.UserOrderDetailsModal;
import com.example.likhwao.Repository.USER.UserOrdersDetailsEntityRepository;
import com.example.likhwao.Repository.WRITER.OrderWriterActionEntityRepository;
import com.example.likhwao.Repository.WRITER.WriterWorkRepository;
import com.example.likhwao.Repository.WRITER.WritersDetailsEntityRepository;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;

import jakarta.transaction.Transactional;

@Service
public class WriterOrderStatusServices {

    @Autowired
    private WritersDetailsEntityRepository wder;

    @Autowired
    private UserOrdersDetailsEntityRepository uder;

    @Autowired
    private OrderWriterActionEntityRepository owaer;

    @Autowired
    private WriterWorkRepository wwr;

   @Transactional
public void orderStatus(String token , UserOrderDetailsModal udm) {

    try {
        token = token.substring(7);
        FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);
        String uid = decoded.getUid();

        WriterDetailsEntity writer = wder.findByFirebaseUid(uid)
                .orElseThrow(() -> new RuntimeException("Writer not found"));

        Long orderId = udm.getId();
        String action = udm.getWriterAssignmentStatus();

        if(action.equals("ACCEPT")) {

            UserOrdersDetailsEntity order = uder
                .findByIdAndWriterAssignmentStatus(orderId, "FINDING_WRITER")
                .orElseThrow(() -> new RuntimeException("Order already taken"));

            order.setWriterAssignmentStatus("ACCEPTED");
            order.setWriter(writer);
            order.setWriterFirebaseUid(uid);

            uder.save(order);
            updateFirebase(order);

            List<WriterWorkEntity> works = wwr.findbyOrderId(orderId);
            for(WriterWorkEntity w : works){
                w.setWriterAssignmentStatus("ACCEPTED");
                wwr.save(w);
            }

            return; 
        }

      

        UserOrdersDetailsEntity order = uder.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        if (order.getWriterFirebaseUid() == null || 
            !order.getWriterFirebaseUid().equals(uid)) {
            throw new RuntimeException("Unauthorized");
        }

        order.setWriterAssignmentStatus(action);
        uder.save(order);

        updateFirebase(order);

        List<WriterWorkEntity> works = wwr.findbyOrderId(orderId);

        for(WriterWorkEntity w : works){
            w.setWriterAssignmentStatus(action);
            wwr.save(w);
        }

        
        OrderWriterActionEntity owae = owaer
            .findByWriterAndOrder(writer , order)
            .orElseGet(() -> {
                OrderWriterActionEntity newEntity = new OrderWriterActionEntity();
                newEntity.setOrder(order);
                newEntity.setWriter(writer);
                newEntity.setUser(order.getUser());
                return newEntity;
            });

        owae.setAction(action);
        owaer.save(owae);

    } catch(Exception e) {
        throw new RuntimeException("Order status update failed", e);
    }
}



    public void updateFirebase(UserOrdersDetailsEntity order) {

        System.out.println("ORDER STATUS :-  " + order.getWriterAssignmentStatus() );

    Firestore db = FirestoreClient.getFirestore();

    Map<String, Object> map = new HashMap<>();
    map.put("status", order.getWriterAssignmentStatus());
    map.put("writerId", order.getWriter().getId());
    map.put("writerName", order.getWriter().getName());
    map.put("writerFirebaseUid", order.getWriterFirebaseUid());

    db.collection("orders")
      .document(order.getId().toString())
      .update(map);
}


    
}
