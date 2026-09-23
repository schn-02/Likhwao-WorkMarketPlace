import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:likho/ApiConfig/apiConfig.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/InProgressOrderScreens/OrderWorkingScreen.dart';
import 'package:likho/Model/OrdersDetailsModel.dart';
import 'package:slide_to_act/slide_to_act.dart';

class Inprogressorderscreen extends StatefulWidget {
  final VoidCallback goToReviewTab;

  const Inprogressorderscreen({
    super.key,
    required this.goToReviewTab,
  });

  @override
  State<Inprogressorderscreen> createState() => _InprogressorderscreenState();
}

class _InprogressorderscreenState extends State<Inprogressorderscreen> {
  Stream<QuerySnapshot>? orderStream;

  StreamSubscription? orderListner;
  bool isUpdatingStatus = false;
  int? updatingOrderId;

  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  String selectedDeadlineFilter = "All";
  String selectedStatusFilter = "All";

  final List<String> deadlineFilters = [
    "All",
    "Fast",
    "Urgent",
    "Normal",
  ];

  final List<String> statusFilters = [
    "All",
    "Paid",
    "Pending",
  ];

  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);

  final Color paymentPendingBg = const Color(0xFFFFFBF2);
  final Color paymentPendingColor = const Color(0xFFFFB000);
  final Color paymentPendingText = const Color(0xFF9B6200);

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final uid = user.uid;

    orderStream = FirebaseFirestore.instance
        .collection("orders")
        .where("status", whereIn: ["ACCEPTED", "IN_PROGRESS"])
        .where("writerFirebaseUid", isEqualTo: uid)
        .snapshots();
  }

  @override
  void dispose() {
    orderListner?.cancel();
    searchController.dispose();
    super.dispose();
  }

  bool checkSearchFilter(Map<String, dynamic> data) {
    if (searchText.trim().isEmpty) {
      return true;
    }

    final query = searchText.trim().toLowerCase();

    final String orderId = data['orderId']?.toString().toLowerCase() ?? "";
    final String typeOfWork =
        data['typeOfWork']?.toString().toLowerCase() ?? "";
    final String filePageCount =
        data['filePageCount']?.toString().toLowerCase() ?? "";
    final String totalOrderAmount =
        data['totalOrderAmount']?.toString().toLowerCase() ?? "";
    final String selectedLanguage =
        data['selectedLanguage']?.toString().toLowerCase() ?? "";
    final String deadline = data['deadline']?.toString().toLowerCase() ?? "";
    final String status = data['status']?.toString().toLowerCase() ?? "";
    final String urgency = data['urgency']?.toString().toLowerCase() ?? "";
    final String selectedInkColor =
        data['InkColor']?.toString().toLowerCase() ??
            data['selectedInkColor']?.toString().toLowerCase() ??
            "";
    final String selectedNotebookType =
        data['NotebookType']?.toString().toLowerCase() ??
            data['selectedNotebook']?.toString().toLowerCase() ??
            "";
    final String paymentStatus =
        data['paymentStatus']?.toString().toLowerCase() ?? "";
    final String orderStatus =
        data['orderStatus']?.toString().toLowerCase() ?? "";

    return orderId.contains(query) ||
        typeOfWork.contains(query) ||
        filePageCount.contains(query) ||
        totalOrderAmount.contains(query) ||
        selectedLanguage.contains(query) ||
        deadline.contains(query) ||
        status.contains(query) ||
        urgency.contains(query) ||
        selectedInkColor.contains(query) ||
        selectedNotebookType.contains(query) ||
        paymentStatus.contains(query) ||
        orderStatus.contains(query);
  }

  bool checkDeadlineFilter(Map<String, dynamic> data) {
    if (selectedDeadlineFilter == "All") {
      return true;
    }

    final urgency = data['urgency']?.toString().toLowerCase().trim() ?? "";
    final selected = selectedDeadlineFilter.toLowerCase();

    if (selected == "fast") {
      return urgency.contains("fast");
    }

    if (selected == "urgent") {
      return urgency.contains("urgent");
    }

    if (selected == "normal") {
      return urgency.contains("normal") || urgency.isEmpty;
    }

    return true;
  }

  bool checkStatusFilter(Map<String, dynamic> data) {
    if (selectedStatusFilter == "All") {
      return true;
    }

    final status = data['status']?.toString().toUpperCase().trim() ?? "";
    final selected = selectedStatusFilter.toLowerCase();


    if (selected == "paid") {
      return isPaymentPaid(data);
    }

    if (selected == "pending") {
      return isPaymentPending(data);
    }

    return true;
  }

  List<QueryDocumentSnapshot> applyFilters(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final bool searchMatched = checkSearchFilter(data);
      final bool deadlineMatched = checkDeadlineFilter(data);
      final bool statusMatched = checkStatusFilter(data);

      return searchMatched && deadlineMatched && statusMatched;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Column(
        children: [
          searchAndFilterLayout(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: orderStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);

                  return Center(
                    child: Text(
                      "Something went wrong",
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: purpleColor,
                      strokeWidth: 2.4,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return noOrderLayout(
                    title: "No active orders",
                    message: "Accepted and in-progress orders will appear here.",
                  );
                }

                final docs = applyFilters(snapshot.data!.docs);

                if (docs.isEmpty) {
                  return noOrderLayout(
                    title: "No matching orders",
                    message: "Try changing your search text or filter.",
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 82),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    if (isUpdatingStatus &&
                        updatingOrderId == data['orderId'] &&
                        data['status'] == "IN_PROGRESS") {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            isUpdatingStatus = false;
                            updatingOrderId = null;
                          });
                        }
                      });
                    }

                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Orderworkingscreen(
                              orderId: data['orderId'],
                            ),
                          ),
                        );

                        if (result == "goToReviewTab") {
                          widget.goToReviewTab();
                        }
                      },
                      child: sampleLayoutOfOrderDetails(data),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget searchAndFilterLayout() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: bgColor,
      child: Column(
        children: [
          Container(
            height: 41,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.grey.withOpacity(0.16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.026),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: primaryColor.withOpacity(0.42),
                  size: 20,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search active orders...",
                      hintStyle: TextStyle(
                        color: primaryColor.withOpacity(0.38),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),

                if (searchText.trim().isNotEmpty)
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      searchController.clear();
                      setState(() {
                        searchText = "";
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Icon(
                        Icons.close_rounded,
                        color: primaryColor.withOpacity(0.48),
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: deadlineFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final filter = deadlineFilters[index];
                final bool isSelected = selectedDeadlineFilter == filter;

                return filterChipLayout(
                  title: filter,
                  icon: getDeadlineFilterIcon(filter),
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      selectedDeadlineFilter = filter;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 7),

          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: statusFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final filter = statusFilters[index];
                final bool isSelected = selectedStatusFilter == filter;

                return filterChipLayout(
                  title: filter,
                  icon: getStatusFilterIcon(filter),
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      selectedStatusFilter = filter;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget filterChipLayout({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? purpleColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? purpleColor : purpleColor.withOpacity(0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.022),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : purpleColor,
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : purpleColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getDeadlineFilterIcon(String filter) {
    switch (filter.toLowerCase()) {
      case "fast":
        return Icons.flash_on_rounded;
      case "urgent":
        return Icons.local_fire_department_rounded;
      case "normal":
        return Icons.schedule_rounded;
      default:
        return Icons.tune_rounded;
    }
  }

  IconData getStatusFilterIcon(String filter) {
    switch (filter.toLowerCase()) {
      case "paid":
        return Icons.verified_rounded;
      case "pending":
        return Icons.info_outline_rounded;
      default:
        return Icons.filter_alt_rounded;
    }
  }

  Widget sampleLayoutOfOrderDetails(Map<String, dynamic> data) {
    String typeOfWork = data['typeOfWork']?.toString() ?? "Not Get";
    String filePageCount = data['filePageCount']?.toString() ?? "-1";
    String totalOrderAmount = data['totalOrderAmount']?.toString() ?? "-1";

    String selectedLanguage =
        data['selectedLanguage']?.toString() ?? "Not Selected";

    String deadline = data['deadline']?.toString() ?? " ";

    String status = data['status']?.toString() ?? "ACCEPTED";

    String selectedInkColor = data['InkColor']?.toString() ??
        data['selectedInkColor']?.toString() ??
        "Blue";

    String selectedNotebookType = data['NotebookType']?.toString() ??
        data['selectedNotebook']?.toString() ??
        "Single Line";

    final bool paymentPending = isPaymentPending(data);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: paymentPending ? paymentPendingBg : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: paymentPending
              ? paymentPendingColor.withOpacity(0.20)
              : Colors.grey.withOpacity(0.09),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: paymentPending
                ? paymentPendingColor.withOpacity(0.045)
                : Colors.black.withOpacity(0.040),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            orderCardTopLayout(
              typeOfWork,
              filePageCount,
              totalOrderAmount,
              status,
              paymentPending,
            ),

            if (paymentPending) ...[
              const SizedBox(height: 7),
              paymentPendingInfoLayout(),
            ],

            const SizedBox(height: 9),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      orderSmallInfoRow(
                        Icons.language_rounded,
                        "Language",
                        selectedLanguage,
                        paymentPending,
                      ),
                      const SizedBox(height: 7),
                      orderSmallInfoRow(
                        Icons.calendar_month_rounded,
                        "Deadline",
                        formatDate(deadline),
                        paymentPending,
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 49,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: paymentPending
                      ? paymentPendingColor.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.13),
                ),

                Expanded(
                  child: Column(
                    children: [
                      orderSmallInfoRow(
                        Icons.water_drop_outlined,
                        "Ink",
                        selectedInkColor,
                        paymentPending,
                      ),
                      const SizedBox(height: 7),
                      orderSmallInfoRow(
                        Icons.menu_book_rounded,
                        "Notebook",
                        selectedNotebookType,
                        paymentPending,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            if (status == "REVIEW")
              reviewPendingLayout()
            else
              progressLayout(status, paymentPending),

            const SizedBox(height: 9),

            Divider(
              height: 1,
              color: paymentPending
                  ? paymentPendingColor.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.13),
            ),

            const SizedBox(height: 8),

            bottomCardActionLayout(data, paymentPending),
          ],
        ),
      ),
    );
  }

  Widget orderCardTopLayout(
      String typeOfWork,
      String filePageCount,
      String totalOrderAmount,
      String status,
      bool paymentPending,
      ) {
    final int amount = int.tryParse(totalOrderAmount.toString()) ?? 0;
    final int writerEarning = (amount - 10).clamp(0, 999999);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 39,
          width: 39,
          decoration: BoxDecoration(
            color: paymentPending
                ? paymentPendingColor.withOpacity(0.12)
                : const Color(0xFFEDE8FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            paymentPending
                ? Icons.info_outline_rounded
                : Icons.assignment_rounded,
            color: paymentPending ? paymentPendingText : purpleColor,
            size: 20,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                capitalizeText(typeOfWork),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: paymentPending ? paymentPendingText : primaryColor,
                  fontSize: 14,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  smallChipLayout(
                    "$filePageCount Page${filePageCount == "1" ? "" : "s"}",
                    paymentPending
                        ? paymentPendingColor.withOpacity(0.11)
                        : const Color(0xFFEAF3FF),
                    paymentPending ? paymentPendingText : Colors.blue.shade700,
                  ),
                  smallChipLayout(
                    "₹$writerEarning Earning",
                    paymentPending
                        ? paymentPendingColor.withOpacity(0.11)
                        : const Color(0xFFE9F8EF),
                    paymentPending ? paymentPendingText : Colors.green.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 6),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            statusChipLayout(status),
            const SizedBox(height: 5),
            paymentChipLayout(paymentPending),
          ],
        ),
      ],
    );
  }

  Widget paymentPendingInfoLayout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: paymentPendingColor.withOpacity(0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: paymentPendingColor.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: paymentPendingText,
            size: 15,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              "Payment pending. Confirm before final submission.",
              style: TextStyle(
                color: paymentPendingText,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentChipLayout(bool paymentPending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: paymentPending
            ? paymentPendingColor.withOpacity(0.11)
            : const Color(0xFFE9F8EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: paymentPending
              ? paymentPendingColor.withOpacity(0.20)
              : Colors.green.withOpacity(0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            paymentPending ? Icons.info_outline_rounded : Icons.verified_rounded,
            color: paymentPending ? paymentPendingText : Colors.green.shade700,
            size: 11,
          ),

          const SizedBox(width: 3),

          Text(
            paymentPending ? "Pending" : "Paid",
            style: TextStyle(
              color: paymentPending ? paymentPendingText : Colors.green.shade700,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget orderSmallInfoRow(
      IconData icon,
      String label,
      String value,
      bool paymentPending,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: paymentPending
              ? paymentPendingText.withOpacity(0.62)
              : primaryColor.withOpacity(0.58),
          size: 15,
        ),

        const SizedBox(width: 5),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: paymentPending
                      ? paymentPendingText.withOpacity(0.56)
                      : primaryColor.withOpacity(0.50),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: paymentPending ? paymentPendingText : primaryColor,
                  fontSize: 11.5,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget progressLayout(String status, bool paymentPending) {
    double progressValue = 0.12;
    String progressText = "Ready to start";

    if (status == "IN_PROGRESS") {
      progressValue = 0.35;
      progressText = "35% done";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: paymentPending
            ? const Color(0xFFFFFCF5)
            : const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: paymentPending
              ? paymentPendingColor.withOpacity(0.15)
              : Colors.grey.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Progress",
                style: TextStyle(
                  color: paymentPending ? paymentPendingText : primaryColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const Spacer(),

              Text(
                progressText,
                style: TextStyle(
                  color: paymentPending ? paymentPendingText : purpleColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 5,
              backgroundColor: paymentPending
                  ? paymentPendingColor.withOpacity(0.16)
                  : const Color(0xFFE6E1FF),
              valueColor: AlwaysStoppedAnimation<Color>(
                paymentPending ? paymentPendingColor : purpleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget reviewPendingLayout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.orange.withOpacity(0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 26,
            width: 26,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE7BD),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              color: Colors.orange.shade700,
              size: 15,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              "Submitted • Waiting for user review",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomCardActionLayout(
      Map<String, dynamic> data,
      bool paymentPending,
      ) {
    String status = data['status']?.toString() ?? "ACCEPTED";

    if (status == "REVIEW") {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 37,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Orderworkingscreen(
                        orderId: data['orderId'],
                      ),
                    ),
                  );

                  if (result == "goToReviewTab") {
                    widget.goToReviewTab();
                  }
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 15,
                ),
                label: const Text("View"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: purpleColor,
                  side: BorderSide(
                    color: purpleColor.withOpacity(0.48),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: SizedBox(
              height: 37,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.goToReviewTab();
                },
                icon: Icon(
                  Icons.schedule_rounded,
                  color: Colors.orange.shade700,
                  size: 15,
                ),
                label: const Text("Review"),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFFFF2D9),
                  foregroundColor: Colors.orange.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 37,
            child: OutlinedButton.icon(
              onPressed: () {
                print("Open Chat clicked");
              },
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 15,
              ),
              label: const Text("Chat"),
              style: OutlinedButton.styleFrom(
                foregroundColor: paymentPending ? paymentPendingText : purpleColor,
                side: BorderSide(
                  color: paymentPending
                      ? paymentPendingColor.withOpacity(0.48)
                      : purpleColor.withOpacity(0.48),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: SizedBox(
            height: 37,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (data['status'] == "ACCEPTED") {
                  setState(() {
                    isUpdatingStatus = true;
                    updatingOrderId = data['orderId'];
                  });

                  Ordersdetailsmodel od = Ordersdetailsmodel(
                    writerAssignmentStatus: "IN_PROGRESS",
                    UserOrderId: data['orderId'],
                    writerFirebaseUid: FirebaseAuth.instance.currentUser?.uid,
                    userFirebaseUid: data['userFirebaseUid'],
                  );

                  await changeStatus(od, data);
                } else {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Orderworkingscreen(
                        orderId: data['orderId'],
                      ),
                    ),
                  );

                  if (result == "goToReviewTab") {
                    widget.goToReviewTab();
                  }
                }
              },
              icon: isUpdatingStatus && updatingOrderId == data['orderId']
                  ? const SizedBox(
                height: 13,
                width: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.edit_note_rounded,
                color: Colors.white,
                size: 15,
              ),
              label: Text(
                isUpdatingStatus && updatingOrderId == data['orderId']
                    ? "Starting"
                    : data['status'] == "IN_PROGRESS"
                    ? "Continue"
                    : "Start",
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: paymentPending ? paymentPendingColor : purpleColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> changeStatus(
      Ordersdetailsmodel od,
      Map<String, dynamic> data,
      ) async {
    print("changeStatusToInProgressFromAccept");

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final token = await user.getIdToken(true);

    final url = Uri.parse(
      "${apiConfig.baseUrl}/api/writer_side/orders/writerAssignmentStatus",
    );

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(od.toJson()),
    );

    print("STATUS: ${response.statusCode}");

    if (response.statusCode != 200) {
      if (mounted) {
        setState(() {
          isUpdatingStatus = false;
          updatingOrderId = null;
        });
      }
    }
  }

  Widget buildSlideAction(Map<String, dynamic> data) {
    final int orderId = data['orderId'];
    final String status = data['status'];

    if (isUpdatingStatus && updatingOrderId == orderId) {
      return Center(
        child: CircularProgressIndicator(
          color: purpleColor,
          strokeWidth: 2.4,
        ),
      );
    }

    if (status == "IN_PROGRESS") {
      return SlideAction(
        text: "  SWIPE TO COMPLETE  ",
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
        outerColor: purpleColor,
        innerColor: Colors.white54,
        onSubmit: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Orderworkingscreen(
                orderId: data['orderId'],
              ),
            ),
          );
        },
      );
    } else if (status == "REVIEW") {
      return InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          print("On Review clicked");
        },
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2D9),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Text(
            "ON REVIEW",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: Colors.orange.shade800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
      return SlideAction(
        outerColor: Colors.green.shade600,
        innerColor: Colors.white54,
        onSubmit: () async {
          setState(() {
            isUpdatingStatus = true;
            updatingOrderId = orderId;
          });

          Ordersdetailsmodel od = Ordersdetailsmodel(
            writerAssignmentStatus: "IN_PROGRESS",
            UserOrderId: data['orderId'],
            writerFirebaseUid: FirebaseAuth.instance.currentUser?.uid,
            userFirebaseUid: data['userFirebaseUid'],
          );

          await changeStatus(od, data);
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "  SWIPE TO START   ",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      );
    }
  }

  Widget statusChipLayout(String status) {
    Color bgColor = const Color(0xFFEAF3FF);
    Color textColor = Colors.blue.shade700;
    IconData icon = Icons.play_circle_outline_rounded;
    String title = "Working";

    if (status == "ACCEPTED") {
      bgColor = const Color(0xFFE9F8EF);
      textColor = Colors.green.shade700;
      icon = Icons.check_circle_outline_rounded;
      title = "Accepted";
    } else if (status == "IN_PROGRESS") {
      bgColor = const Color(0xFFEAF3FF);
      textColor = Colors.blue.shade700;
      icon = Icons.play_circle_outline_rounded;
      title = "Working";
    } else if (status == "REVIEW") {
      bgColor = const Color(0xFFFFF2D9);
      textColor = Colors.orange.shade700;
      icon = Icons.hourglass_top_rounded;
      title = "Review";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 11,
          ),

          const SizedBox(width: 3),

          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget smallChipLayout(
      String text,
      Color bgColor,
      Color textColor,
      ) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 60,
        maxWidth: 120,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  bool isPaymentPaid(Map<String, dynamic> data) {
    final String paymentStatus =
    getValueFromData(data, ["paymentStatus"], "").toUpperCase();

    final String orderStatus =
    getValueFromData(data, ["orderStatus"], "").toUpperCase();

    final String paymentRequired =
    getValueFromData(data, ["paymentRequired"], "").toLowerCase();

    if (paymentRequired == "false") {
      return true;
    }

    if (paymentStatus == "PAID" ||
        paymentStatus == "SUCCESS" ||
        paymentStatus == "CAPTURED") {
      return true;
    }

    if (orderStatus == "PAID" ||
        orderStatus == "SUCCESS" ||
        orderStatus == "CAPTURED") {
      return true;
    }

    return false;
  }

  bool isPaymentPending(Map<String, dynamic> data) {
    if (isPaymentPaid(data)) {
      return false;
    }

    final String paymentStatus =
    getValueFromData(data, ["paymentStatus"], "").toUpperCase();

    final String orderStatus =
    getValueFromData(data, ["orderStatus"], "").toUpperCase();

    final String paymentRequired =
    getValueFromData(data, ["paymentRequired"], "").toLowerCase();

    if (paymentRequired == "true") {
      return true;
    }

    if (paymentStatus == "PENDING" ||
        paymentStatus == "FAILED" ||
        paymentStatus == "NOT_PAID" ||
        paymentStatus == "UNPAID") {
      return true;
    }

    if (orderStatus == "PENDING" ||
        orderStatus == "FAILED" ||
        orderStatus == "NOT_PAID" ||
        orderStatus == "UNPAID") {
      return true;
    }

    if (paymentStatus.isEmpty &&
        orderStatus.isEmpty &&
        paymentRequired.isEmpty) {
      return true;
    }

    return true;
  }

  String getValueFromData(
      Map<String, dynamic> data,
      List<String> keys,
      String defaultValue,
      ) {
    for (String key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key].toString().trim();

        if (value.isNotEmpty && value != "null") {
          return value;
        }
      }
    }

    return defaultValue;
  }

  Widget noOrderLayout({
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 66,
              width: 66,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE8FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                color: purpleColor,
                size: 32,
              ),
            ),

            const SizedBox(height: 13),

            Text(
              title,
              style: TextStyle(
                color: primaryColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor.withOpacity(0.55),
                fontSize: 12.5,
                height: 1.30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String capitalizeText(String text) {
    if (text.trim().isEmpty) {
      return text;
    }

    return text
        .split(" ")
        .map((word) {
      if (word.isEmpty) {
        return word;
      }

      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    })
        .join(" ");
  }

  String formatDate(String date) {
    if (date.contains("-")) {
      final parts = date.split("-");

      if (parts.length == 3) {
        return "${parts[2]} ${monthName(parts[1])} ${parts[0]}";
      }
    }

    return date;
  }

  String monthName(String month) {
    switch (month) {
      case "01":
        return "Jan";
      case "02":
        return "Feb";
      case "03":
        return "Mar";
      case "04":
        return "Apr";
      case "05":
        return "May";
      case "06":
        return "Jun";
      case "07":
        return "Jul";
      case "08":
        return "Aug";
      case "09":
        return "Sep";
      case "10":
        return "Oct";
      case "11":
        return "Nov";
      case "12":
        return "Dec";
      default:
        return month;
    }
  }
}