import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:likho/ApiConfig/apiConfig.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/AvailableOrderScreens/AvailableOrderScreen.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/CompletedScreen/CompletedOrderScreen.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/InProgressOrderScreens/InProgressOrderScreen.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/ReviewScreen/reviewScreen.dart';

class Ordersscreen extends StatefulWidget {
  const Ordersscreen({super.key});

  @override
  State<Ordersscreen> createState() => _OrdersscreenState();
}

class _OrdersscreenState extends State<Ordersscreen>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);

  late TabController _tabController;

  int activeOrders = 0;
  double todayEarning = 0;
  int reviewOrders = 0;

  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 4,
      vsync: this,
    );

    getHomeStatsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _compactHeader(),
            _compactStats(),
            _tabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const Availableorderscreen(),
                  Inprogressorderscreen(
                    goToReviewTab: () {
                      _tabController.animateTo(2);
                      getHomeStatsData();
                    },
                  ),
                  const reviewScreen(),
                  const Completedorderscreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, Writer 👋",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Manage your assignments",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9B7BFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compactStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _statItem(
            icon: Icons.assignment_rounded,
            iconColor: purpleColor,
            iconBgColor: const Color(0xFFEDE8FF),
            title: "Active",
            value: isLoadingStats ? "..." : activeOrders.toString(),
            valueColor: primaryColor,
          ),
          _divider(),
          _statItem(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: Colors.green,
            iconBgColor: const Color(0xFFE8F8EF),
            title: "Earning",
            value: isLoadingStats
                ? "..."
                : "₹${todayEarning.toStringAsFixed(0)}",
            valueColor: Colors.green,
          ),
          _divider(),
          _statItem(
            icon: Icons.schedule_rounded,
            iconColor: Colors.orange,
            iconBgColor: const Color(0xFFFFF1E2),
            title: "Review",
            value: isLoadingStats ? "..." : reviewOrders.toString(),
            valueColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 38,
      width: 1,
      color: Colors.grey.withOpacity(0.18),
    );
  }

  Widget _tabs() {
    return Container(
      height: 48,
      color: bgColor,
      child: TabBar(
        controller: _tabController,
        indicatorColor: purpleColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: purpleColor,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        tabs: const [
          Tab(text: "Available"),
          Tab(text: "In Progress"),
          Tab(text: "In Review"),
          Tab(text: "Completed"),
        ],
      ),
    );
  }

  Future<void> getHomeStatsData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        activeOrders = 0;
        todayEarning = 0;
        reviewOrders = 0;
        isLoadingStats = false;
      });

      print("Home stats error: Firebase user is null");
      return;
    }

    if (!mounted) return;

    setState(() {
      isLoadingStats = true;
    });

    try {
      final token = await user.getIdToken(true);

      final url = Uri.parse(
        "${apiConfig.baseUrl}/api/writer_side/home/stats",
      );

      print("Home stats API URL: $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("Home stats status code: ${response.statusCode}");
      print("Home stats response body: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final item = jsonDecode(response.body);

        setState(() {
          activeOrders = item["activeOrders"] ?? 0;

          final earningValue = item["todayEarning"] ?? 0;
          if (earningValue is int) {
            todayEarning = earningValue.toDouble();
          } else if (earningValue is double) {
            todayEarning = earningValue;
          } else {
            todayEarning = double.tryParse(earningValue.toString()) ?? 0;
          }

          reviewOrders = item["reviewOrders"] ?? 0;
          isLoadingStats = false;
        });
      } else {
        setState(() {
          isLoadingStats = false;
        });

        print("Home stats failed: ${response.statusCode}");
        print("Home stats failed body: ${response.body}");
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingStats = false;
      });

      print("Home stats error: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}