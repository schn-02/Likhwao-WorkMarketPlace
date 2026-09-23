package com.example.likhwao.controller.USER;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.likhwao.DTO.USER.WriterFeedbackResponse;
import com.example.likhwao.DTO.WRITER.WriterFeedbackRequestDTO;
import com.example.likhwao.Services.USER.WriterFeedbackService;


@RestController
@RequestMapping("/api/user_side")
public class WriterFeedbackController {

    private final WriterFeedbackService writerFeedbackService;

    public WriterFeedbackController(WriterFeedbackService writerFeedbackService) {
        this.writerFeedbackService = writerFeedbackService;
    }

    @PostMapping("/feedback/submit")
    public ResponseEntity<WriterFeedbackResponse> submitFeedback(
            @RequestBody WriterFeedbackRequestDTO request
    ) {
        try {

            System.out.println("Api hit check !!");
            WriterFeedbackResponse response = writerFeedbackService.submitFeedback(request);

            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(response);

        } catch (RuntimeException e) {
            return ResponseEntity
                    .badRequest()
                    .body(WriterFeedbackResponse.failed(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(WriterFeedbackResponse.failed("Something went wrong"));
        }
    }
}