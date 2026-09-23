package com.example.likhwao.DTO.WRITER;


import java.util.List;

public class WriterAllOrdersResponseDTO {

    private List<FetchUserOrdersDTO> availableOrders;
    private List<FetchUserOrdersDTO> inProgressOrders;
    private List<FetchUserOrdersDTO> reviewOrders;
    private List<FetchUserOrdersDTO> completedOrders;

    public WriterAllOrdersResponseDTO() {
    }

    public WriterAllOrdersResponseDTO(
            List<FetchUserOrdersDTO> availableOrders,
            List<FetchUserOrdersDTO> inProgressOrders,
            List<FetchUserOrdersDTO> reviewOrders,
            List<FetchUserOrdersDTO> completedOrders
    ) {
        this.availableOrders = availableOrders;
        this.inProgressOrders = inProgressOrders;
        this.reviewOrders = reviewOrders;
        this.completedOrders = completedOrders;
    }

    public List<FetchUserOrdersDTO> getAvailableOrders() {
        return availableOrders;
    }

    public void setAvailableOrders(List<FetchUserOrdersDTO> availableOrders) {
        this.availableOrders = availableOrders;
    }

    public List<FetchUserOrdersDTO> getInProgressOrders() {
        return inProgressOrders;
    }

    public void setInProgressOrders(List<FetchUserOrdersDTO> inProgressOrders) {
        this.inProgressOrders = inProgressOrders;
    }

    public List<FetchUserOrdersDTO> getReviewOrders() {
        return reviewOrders;
    }

    public void setReviewOrders(List<FetchUserOrdersDTO> reviewOrders) {
        this.reviewOrders = reviewOrders;
    }

    public List<FetchUserOrdersDTO> getCompletedOrders() {
        return completedOrders;
    }

    public void setCompletedOrders(List<FetchUserOrdersDTO> completedOrders) {
        this.completedOrders = completedOrders;
    }
}