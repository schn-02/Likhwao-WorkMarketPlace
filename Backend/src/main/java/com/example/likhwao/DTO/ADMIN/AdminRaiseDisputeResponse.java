package com.example.likhwao.DTO.ADMIN;


public class AdminRaiseDisputeResponse {

    private String status;
    private String message;
    private Long disputeId;
    private Long orderId;
    private String disputeStatus;
    private String orderStatus;
    private String writerSubmissionVersion;

    

    public AdminRaiseDisputeResponse() {
    }

    public AdminRaiseDisputeResponse(
            String status,
            String message,
            Long disputeId,
            Long orderId,
            String disputeStatus,
            String orderStatus,
            String writerSubmissionVersion
    ) {
        this.status = status;
        this.message = message;
        this.disputeId = disputeId;
        this.orderId = orderId;
        this.disputeStatus = disputeStatus;
        this.orderStatus = orderStatus;
        this.writerSubmissionVersion = writerSubmissionVersion;
    }

    public String getStatus() {
        return status;
    }

    public String getMessage() {
        return message;
    }

    public Long getDisputeId() {
        return disputeId;
    }

    public Long getOrderId() {
        return orderId;
    }

    public String getDisputeStatus() {
        return disputeStatus;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public String getWriterSubmissionVersion() {
        return writerSubmissionVersion;
    }
}