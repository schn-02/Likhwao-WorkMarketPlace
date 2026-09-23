package com.example.likhwao.controller.WRITER;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.Model.AuthModel;
import com.example.likhwao.Services.WRITER.WriterDetailsServices;

@RestController
@RequestMapping("/api/writer_side/auth")
public class SaveWriterDetailsController {

    @Autowired
    private WriterDetailsServices writerDetailsServices;

    @PostMapping("/SaveWriterDetails")
    public ResponseEntity<?> login(@RequestBody AuthModel dto)
    {
        System.out.println("Save Writer call");
                System.out.println(dto);

        writerDetailsServices.saveWriters(dto);


        return ResponseEntity.ok(Map.of(
            "status" ,true ,
            "message" ,"Writer details saves"
        ));
       
    }

      @GetMapping("/checkWriter")
    public ResponseEntity<?> getData(@RequestParam String deviceId,
    @RequestParam  String firebaseUid) 
    {
    return ResponseEntity.ok(writerDetailsServices.checkWriters(deviceId , firebaseUid));
      
       }



   @GetMapping("/public/canCreateAccount")
   public ResponseEntity<Map<String, Boolean>> canCreateAccount(@RequestParam String deviceId  , @RequestParam String email) {
       
            System.out.println("ALOWED :-");

        boolean allowed = writerDetailsServices.canCreateAccount(deviceId , email);
        return ResponseEntity.ok(Map.of(
            "allowed",allowed
        ));
   }
}
