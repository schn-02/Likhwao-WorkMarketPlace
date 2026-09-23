package com.example.likhwao.DTO.WRITER;

public class HomeStatsResponse {

  public  int activeOrders;
  public double todayEarning;
  public int reviewOrders;

  public int getActiveOrders() {
    return activeOrders;
  }
  public void setActiveOrders(int activeOrders) {
    this.activeOrders = activeOrders;
  }
  public double getTodayEarning() {
    return todayEarning;
  }
  public void setTodayEarning(double todayEarning) {
    this.todayEarning = todayEarning;
  }
  public int getReviewOrders() {
    return reviewOrders;
  }
  public void setReviewOrders(int reviewOrders) {
    this.reviewOrders = reviewOrders;
  }
  public HomeStatsResponse(int activeOrders, double todayEarning, int reviewOrders) {
    this.activeOrders = activeOrders;
    this.todayEarning = todayEarning;
    this.reviewOrders = reviewOrders;
  }

  
 
  

}
