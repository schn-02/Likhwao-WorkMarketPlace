import 'package:adminlikhwao/Authentication/Login.dart';
import 'package:adminlikhwao/BottomNavigationBar/Dashboard.dart';
import 'package:adminlikhwao/Model/AdminOrderModel.dart';
import 'package:adminlikhwao/Model/DashboardStatsModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final Color bg = const Color(0xFF07111F);
  final Color card = const Color(0xFF0E1B2E);
  final Color card2 = const Color(0xFF13243A);
  final Color primary = const Color(0xFF4FA3FF);
  final Color text = const Color(0xFFF3F7FF);
  final Color subText = const Color(0xFF9FB0C7);
  final Color border = const Color(0xFF22344D);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> _ordersStream() {
    return _firestore
        .collection("orders")
        .orderBy("updatedAtTimestamp", descending: true)
        .limit(50)
        .snapshots();
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: border),
          ),
          title: Text(
            "Logout?",
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to logout from Likhwao Admin?",
            style: TextStyle(
              color: subText,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: subText),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
            (route) => false,
      );
    } catch (e) {
      debugPrint("LOGOUT ERROR : $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logout failed. Please try again."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _ordersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingView();
            }

            if (snapshot.hasError) {
              return _errorView(snapshot.error.toString());
            }

            final docs = snapshot.data?.docs ?? [];

            final orders = docs.map((doc) {
              return AdminOrder.fromFirestore(doc.id, doc.data());
            }).toList();

            final stats = DashboardStats.fromOrders(orders);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _sectionTitle("Overview"),
                      const SizedBox(height: 12),
                      _statsGrid(stats),
                      const SizedBox(height: 24),
                      _recentOrderHeader(),
                      const SizedBox(height: 12),
                      orders.isEmpty ? _emptyOrders() : _recentOrders(orders),
                      const SizedBox(height: 24),
                      _sectionTitle("Promotion Banner"),
                      const SizedBox(height: 12),
                      _promotionBanner(),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _loadingView() {
    return Center(
      child: CircularProgressIndicator(
        color: primary,
      ),
    );
  }

  Widget _errorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          "Something went wrong.\n$error",
          textAlign: TextAlign.center,
          style: TextStyle(color: subText),
        ),
      ),
    );
  }

  Widget _emptyOrders() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, color: subText, size: 44),
          const SizedBox(height: 10),
          Text(
            "No orders found",
            style: TextStyle(
              color: text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "New orders will appear here automatically.",
            style: TextStyle(color: subText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1B33),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Colors.white, size: 28),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              "Dashboard",
              style: TextStyle(
                color: text,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            tooltip: "Notifications",
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none,
              color: text,
              size: 28,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: "Logout",
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
              color: Colors.redAccent,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: text,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _statsGrid(DashboardStats stats) {
    final items = [
      _Stat(
        "Total Orders",
        stats.totalOrders.toString(),
        "All time",
        Icons.assignment,
        primary,
      ),
      _Stat(
        "Finding Writer",
        stats.findingWriter.toString(),
        "Pending",
        Icons.access_time,
        Colors.orange,
      ),
      _Stat(
        "On going",
        ((stats.inProgress ?? 0) + (stats.accepted ?? 0)).toString(),
        "Ongoing",
        Icons.description,
        Colors.blueAccent,
      ),
      _Stat(
        "Review / Dispute",
        stats.reviewOrDispute.toString(),
        "Action needed",
        Icons.error_outline,
        Colors.redAccent,
      ),
      _Stat(
        "Completed",
        stats.completed.toString(),
        "Done",
        Icons.check_circle_outline,
        Colors.greenAccent,
      ),
      _Stat(
        "Revenue",
        "₹${_formatAmount(stats.revenue)}",
        "Paid orders",
        Icons.currency_rupee,
        Colors.purpleAccent,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final int count = constraints.maxWidth > 700 ? 3 : 2;

        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 118,
          ),
          itemBuilder: (context, index) => _statCard(items[index]),
        );
      },
    );
  }

  String _formatAmount(num amount) {
    if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(2)}L";
    }

    if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(1)}K";
    }

    return amount.toStringAsFixed(0);
  }

  Widget _statCard(_Stat item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(item.icon, color: item.color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: subText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.value,
                    style: TextStyle(
                      color: text,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: item.subtitle == "Action needed"
                          ? Colors.redAccent
                          : subText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentOrderHeader() {
    return Row(
      children: [
        Expanded(child: _sectionTitle("Recent Orders")),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to all orders screen.
          },
          child: Text(
            "View All",
            style: TextStyle(
              color: primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _recentOrders(List<AdminOrder> orders) {
    final recentOrders = orders.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: ListView.separated(
        itemCount: recentOrders.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => Divider(color: border, height: 1),
        itemBuilder: (context, index) {
          final order = recentOrders[index];
          final statusColor = _getStatusColor(order.status, order.hasDispute);

          return InkWell(
            onTap: () {
              // Important:
              // Yaha par SQL backend API wali detail screen open hogi.
              // Firestore sirf list/quick dashboard ke liye hai.
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => AdminOrderDetailScreen(
              //       orderId: order.orderId,
              //     ),
              //   ),
              // );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.receipt_long, color: primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "#ORD${order.orderId.toString()}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: text,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "₹${order.totalOrderAmount.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${order.userName} • ${order.typeOfWork} • ${order.userFilePageCount} Pages",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: subText,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Writer: ${order.writerName.isEmpty ? "Not assigned" : order.writerName}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: subText,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _statusChip(order.displayStatus, statusColor),
                            _smallChip(order.paymentStatus),
                            _smallChip(order.urgency),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: subText),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
       status,

        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _smallChip(String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: card2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: subText,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status, bool hasDispute) {
    if (hasDispute) return Colors.redAccent;

    final s = status.toUpperCase();

    if (s == "FINDING_WRITER") return Colors.orange;
    if (s == "IN_PROGRESS") return Colors.blueAccent;
    if (s == "REVIEW") return Colors.redAccent;
    if (s == "REQUEST_CHANGES") return Colors.deepOrangeAccent;
    if (s == "COMPLETED") return Colors.greenAccent;
    if (s == "CANCELLED" || s == "REJECT") return Colors.redAccent;

    return primary;
  }

  Widget _promotionBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.campaign_outlined,
              color: primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Promotion Banner",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: text,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Add / edit active banner",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // TODO: Promotion banner manage screen.
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: Text(
              "Manage",
              style: TextStyle(color: primary),
            ),
          ),
        ],
      ),
    );
  }
}


class _Stat {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  _Stat(
      this.title,
      this.value,
      this.subtitle,
      this.icon,
      this.color,
      );
}