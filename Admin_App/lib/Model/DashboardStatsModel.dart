import 'package:adminlikhwao/Model/AdminOrderModel.dart';

class DashboardStats {
  final int totalOrders;
  final int findingWriter;
  final int inProgress;
  final int accepted;
  final int reviewOrDispute;
  final int completed;
  final double revenue;

  DashboardStats({
    required this.totalOrders,
    required this.findingWriter,
    required this.inProgress,
    required this.reviewOrDispute,
    required this.completed,
    required this.revenue,
    required this.accepted,
  });

  factory DashboardStats.fromOrders(List<AdminOrder> orders) {
    int findingWriter = 0;
    int inProgress = 0;
    int reviewOrDispute = 0;
    int completed = 0;
    int accepted = 0;
    double revenue = 0;

    for (final order in orders) {
      final status = order.status.toUpperCase();

      if (status == "FINDING_WRITER") {
        findingWriter++;
      } else if (status == "IN_PROGRESS") {
        inProgress++;
      } else if (status == "REVIEW" ||
          status == "REQUEST_CHANGES" ||
          order.hasDispute ||
          order.adminActionRequired) {
        reviewOrDispute++;
      } else if (status == "COMPLETED") {
        completed++;
      }else if (status =="ACCEPTED") {
        accepted++;
      }

      if (order.paymentStatus.toUpperCase() == "PAID") {
        revenue += order.totalOrderAmount;
      }
    }

    return DashboardStats(
      totalOrders: orders.length,
      findingWriter: findingWriter,
      inProgress: inProgress,
      reviewOrDispute: reviewOrDispute,
      completed: completed,
      revenue: revenue,
      accepted: accepted,
    );
  }
}
