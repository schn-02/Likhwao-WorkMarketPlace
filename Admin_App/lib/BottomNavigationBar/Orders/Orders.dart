import 'package:adminlikhwao/BottomNavigationBar/Disputes/AdminDisputeOrderDetailsScreen.dart';
import 'package:adminlikhwao/BottomNavigationBar/Orders/OrdersViewDetailsScreen.dart';
import 'package:adminlikhwao/Model/AdminOrderModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  int selectedTab = 0;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  final Color bg = const Color(0xFF07111F);
  final Color card = const Color(0xFF0E1B2E);
  final Color card2 = const Color(0xFF13243A);
  final Color primary = const Color(0xFF4FA3FF);
  final Color textColor = const Color(0xFFF3F7FF);
  final Color subText = const Color(0xFF9FB0C7);
  final Color border = const Color(0xFF22344D);

  final List<String> tabs = const [
    "All",
    "Finding",
    "Progress",
    "Review",
    "Completed",
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Stream<List<AdminOrder>> _ordersStream() {
    return FirebaseFirestore.instance
        .collection("orders")
        .orderBy("createdAtTimestamp", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AdminOrder.fromFirestore(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  List<AdminOrder> _getFilteredOrders(List<AdminOrder> orders) {
    List<AdminOrder> result = orders;

    if (selectedTab == 1) {
      result = result.where((o) => o.isFindingWriter).toList();
    } else if (selectedTab == 2) {
      result = result.where((o) => o.isInProgress).toList();
    } else if (selectedTab == 3) {
      result = result.where((o) => o.isReviewOrDispute).toList();
    } else if (selectedTab == 4) {
      result = result.where((o) => o.isCompleted).toList();
    }

    result = result.where((o) => o.matchesSearch(searchQuery)).toList();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 14),
            _tabs(),
            const SizedBox(height: 12),
            _searchBox(),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<AdminOrder>>(
                stream: _ordersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _loadingState();
                  }

                  if (snapshot.hasError) {
                    return _errorState(snapshot.error.toString());
                  }

                  final List<AdminOrder> orders = snapshot.data ?? [];
                  final List<AdminOrder> filteredOrders =
                  _getFilteredOrders(orders);

                  if (filteredOrders.isEmpty) {
                    return _emptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _orderCard(filteredOrders[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      color: const Color(0xFF0B1B33),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Orders",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(Icons.receipt_long, color: textColor),
          const SizedBox(width: 14),
          Icon(Icons.filter_list, color: textColor),
        ],
      ),
    );
  }

  Widget _tabs() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final bool active = selectedTab == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                setState(() {
                  selectedTab = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? primary.withOpacity(0.18) : card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: active ? primary : border),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: active ? primary : subText,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: subText, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                ),
                cursorColor: primary,
                decoration: InputDecoration(
                  hintText: "Search order, user, writer...",
                  hintStyle: TextStyle(
                    color: subText,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (searchQuery.isNotEmpty)
              InkWell(
                onTap: () {
                  searchController.clear();
                  setState(() {
                    searchQuery = "";
                  });
                },
                child: Icon(Icons.close, color: subText, size: 21),
              )
            else
              Icon(Icons.sort, color: subText, size: 21),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(AdminOrder order) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _iconBox(order.statusColor),
              _smallInfo("Order ID", order.orderCode),
              _smallInfo("Amount", order.amountText),
              _statusChip(order.displayStatus, order.statusColor),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            order.userDisplayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            order.orderTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          _detailsBox(order),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Ordersviewdetailsscreen(
                      orderId: order.orderId,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "View Details",
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsBox(AdminOrder order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _infoLine(
            Icons.description_outlined,
            "${order.typeOfWork} • ${order.pagesText} • ${order.selectedLanguage}",
          ),
          const SizedBox(height: 8),
          _infoLine(
            Icons.upload_file_outlined,
            "File: ${order.userFileName}",
          ),
          const SizedBox(height: 8),
          _infoLine(
            Icons.access_time,
            "Deadline: ${order.deadline}",
            color: Colors.redAccent,
          ),
          const SizedBox(height: 8),
          _infoLine(
            Icons.flash_on_outlined,
            "Urgency: ${order.urgency}",
            color: _urgencyColor(order.urgency),
          ),
          const SizedBox(height: 8),
          _infoLine(
            order.hasWriter ? Icons.edit_outlined : Icons.person_off_outlined,
            order.writerInfo,
            color: order.hasWriter ? subText : Colors.orange,
          ),
          const SizedBox(height: 8),
          _infoLine(
            Icons.local_shipping_outlined,
            "Delivery/Pickup: ${order.deliveryPickupOption}",
          ),
          const SizedBox(height: 8),
          _infoLine(
            Icons.payments_outlined,
            "Payment: ${order.paymentStatus} • Platform Fee: ₹${order.platformFeeAmount.toStringAsFixed(0)}",
            color: order.isPaid ? Colors.greenAccent : Colors.orange,
          ),
        ],
      ),
    );
  }

  Color _urgencyColor(String urgency) {
    if (urgency == "FAST") return Colors.orange;
    if (urgency == "URGENT") return Colors.redAccent;
    return subText;
  }

  Widget _smallInfo(String title, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 125),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: subText, fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(Color color) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.receipt_long, color: color, size: 25),
    );
  }

  Widget _statusChip(String status, Color color) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? subText, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color ?? subText,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: primary,
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: subText, size: 42),
            const SizedBox(height: 12),
            Text(
              "No orders found",
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Try another tab or search keyword",
              style: TextStyle(
                color: subText,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
            const SizedBox(height: 12),
            Text(
              "Something went wrong",
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}