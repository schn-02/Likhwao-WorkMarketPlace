import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:likho/ApiConfig/apiConfig.dart';
import 'package:likho/Model/OrdersDetailsModel.dart';

class Completedorderscreen extends StatefulWidget {
  const Completedorderscreen({super.key});

  @override
  State<Completedorderscreen> createState() => _CompletedorderscreenState();
}

class _CompletedorderscreenState extends State<Completedorderscreen> {
  List<Ordersdetailsmodel> orders = [];
  List<Ordersdetailsmodel> filteredOrders = [];

  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  String selectedDeadlineFilter = "All";

  final List<String> deadlineFilters = [
    "All",
    "Fast",
    "Urgent",
    "Normal",
  ];

  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCompletedData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void applyFilters() {
    final query = searchText.trim().toLowerCase();
    final deadlineFilter = selectedDeadlineFilter.toLowerCase();

    filteredOrders = orders.where((order) {
      final typeOfWork = order.typeOfWork?.toString().toLowerCase() ?? "";
      final pageCount = order.userFilePageCount?.toString().toLowerCase() ?? "";
      final totalAmount = order.totalOrderAmount?.toString().toLowerCase() ?? "";
      final platformFee =
          order.platformFeeAmount?.toString().toLowerCase() ?? "";
      final language =
          order.languageSelectedChips?.toString().toLowerCase() ?? "";
      final deadline =
          order.selectedDeadLineUrgency?.toString().toLowerCase() ?? "";
      final inkColor = order.selectedInkColor?.toString().toLowerCase() ?? "";
      final status =
          order.writerAssignmentStatus?.toString().toLowerCase() ?? "";

      final earning =
      ((order.totalOrderAmount ?? 0) - (order.platformFeeAmount ?? 0))
          .toString()
          .toLowerCase();

      final bool searchMatched = query.isEmpty ||
          typeOfWork.contains(query) ||
          pageCount.contains(query) ||
          totalAmount.contains(query) ||
          platformFee.contains(query) ||
          language.contains(query) ||
          deadline.contains(query) ||
          inkColor.contains(query) ||
          status.contains(query) ||
          earning.contains(query);

      bool deadlineMatched = true;

      if (deadlineFilter == "fast") {
        deadlineMatched = deadline.contains("fast");
      } else if (deadlineFilter == "urgent") {
        deadlineMatched = deadline.contains("urgent");
      } else if (deadlineFilter == "normal") {
        deadlineMatched = deadline.contains("normal") || deadline.isEmpty;
      }

      return searchMatched && deadlineMatched;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Column(
        children: [
          completedTopSection(),

          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: purpleColor,
                strokeWidth: 2.4,
              ),
            )
                : filteredOrders.isNotEmpty
                ? ListView.builder(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 82),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    showCompletedOrderBottomSheet(order);
                  },
                  child: sampleLayoutOfOrderDetails(order),
                );
              },
            )
                : noDataLayout(
              title: orders.isEmpty
                  ? "No completed orders"
                  : "No matching orders",
              message: orders.isEmpty
                  ? "Orders accepted by the user will appear here after completion."
                  : "Try changing your search text or filter.",
            ),
          ),
        ],
      ),
    );
  }

  Widget completedTopSection() {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          completedTopSummary(),

          const SizedBox(height: 7),

          searchLayout(),

          const SizedBox(height: 7),

          filterLayout(),
        ],
      ),
    );
  }

  Widget completedTopSummary() {
    int completedCount = filteredOrders.length;
    int totalEarning = 0;

    for (var order in filteredOrders) {
      totalEarning +=
          ((order.totalOrderAmount ?? 0) - (order.platformFeeAmount ?? 0))
              .toInt();
    }

    return Row(
      children: [
        Expanded(
          child: summaryCardLayout(
            icon: Icons.check_circle_outline_rounded,
            iconBg: const Color(0xFFE9F8EF),
            iconColor: Colors.green.shade700,
            label: "Completed",
            value: "$completedCount Orders",
            valueColor: primaryColor,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: summaryCardLayout(
            icon: Icons.account_balance_wallet_rounded,
            iconBg: const Color(0xFFEDE8FF),
            iconColor: purpleColor,
            label: "Earnings",
            value: "₹$totalEarning",
            valueColor: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget summaryCardLayout({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.024),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.52),
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
                    color: valueColor,
                    fontSize: 13.5,
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

  Widget searchLayout() {
    return Container(
      height: 39,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.grey.withOpacity(0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.024),
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
            size: 19,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  applyFilters();
                });
              },
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: primaryColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: "Search completed orders...",
                hintStyle: TextStyle(
                  color: primaryColor.withOpacity(0.38),
                  fontSize: 12,
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
                  applyFilters();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(
                  Icons.close_rounded,
                  color: primaryColor.withOpacity(0.48),
                  size: 17,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget filterLayout() {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: deadlineFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final filter = deadlineFilters[index];
          final bool isSelected = selectedDeadlineFilter == filter;

          return InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              setState(() {
                selectedDeadlineFilter = filter;
                applyFilters();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? purpleColor : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? purpleColor
                      : purpleColor.withOpacity(0.16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.020),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    getFilterIcon(filter),
                    color: isSelected ? Colors.white : purpleColor,
                    size: 13,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : purpleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData getFilterIcon(String filter) {
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

  Widget sampleLayoutOfOrderDetails(Ordersdetailsmodel order) {
    String typeOfWork = order.typeOfWork ?? "Not Get";

    String userFilePageCount =
    order.userFilePageCount != null ? order.userFilePageCount.toString() : "-1";

    String earning =
        "₹${((order.totalOrderAmount ?? 0) - (order.platformFeeAmount ?? 0)).toString()}";

    String languageSelectedChips =
        order.languageSelectedChips ?? "Not Selected";

    String selectedDeadLineUrgency = order.selectedDeadLineUrgency ?? " ";

    String selectedInkColor = order.selectedInkColor ?? "Blue";

    String completedStatus = order.writerAssignmentStatus ?? "COMPLETED";

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.withOpacity(0.09),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.040),
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
            completedOrderTopLayout(
              typeOfWork,
              userFilePageCount,
              earning,
              completedStatus,
            ),

            const SizedBox(height: 9),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      completedSmallInfoRow(
                        Icons.language_rounded,
                        "Language",
                        languageSelectedChips,
                      ),
                      const SizedBox(height: 7),
                      completedSmallInfoRow(
                        Icons.calendar_month_rounded,
                        "Deadline",
                        selectedDeadLineUrgency,
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 49,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.grey.withOpacity(0.13),
                ),

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      completedSmallInfoRow(
                        Icons.water_drop_outlined,
                        "Ink",
                        selectedInkColor,
                      ),
                      const SizedBox(height: 7),
                      completedSmallInfoRow(
                        Icons.currency_rupee_rounded,
                        "Earning",
                        earning,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            completedProgressLayout(),

            const SizedBox(height: 9),

            Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.13),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 37,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showCompletedOrderBottomSheet(order);
                      },
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 15,
                      ),
                      label: const Text("Summary"),
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
                        print("Download receipt clicked");
                      },
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      label: const Text("Receipt"),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: purpleColor,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget completedOrderTopLayout(
      String typeOfWork,
      String userFilePageCount,
      String earning,
      String completedStatus,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 39,
          width: 39,
          decoration: const BoxDecoration(
            color: Color(0xFFE9F8EF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.task_alt_rounded,
            color: Colors.green.shade700,
            size: 20,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                capitalizeText(typeOfWork),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor,
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
                    "$userFilePageCount Page${userFilePageCount == "1" ? "" : "s"}",
                    const Color(0xFFEAF3FF),
                    Colors.blue.shade700,
                  ),
                  smallChipLayout(
                    earning,
                    const Color(0xFFE9F8EF),
                    Colors.green.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 6),

        completedStatusChipLayout(completedStatus),
      ],
    );
  }

  Widget completedSmallInfoRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: primaryColor.withOpacity(0.58),
          size: 15,
        ),

        const SizedBox(width: 5),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.50),
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
                  color: primaryColor,
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

  Widget completedProgressLayout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F8EF),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.green.withOpacity(0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 26,
            width: 26,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_rounded,
              color: Colors.green.shade700,
              size: 15,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              "Completed • Payment released to writer",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget completedStatusChipLayout(String completedStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F8EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withOpacity(0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.green.shade700,
            size: 11,
          ),

          const SizedBox(width: 3),

          Text(
            "Done",
            style: TextStyle(
              color: Colors.green.shade700,
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
        minWidth: 56,
        maxWidth: 116,
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

  Widget noDataLayout({
    required String title,
    required String message,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight < 0 ? 0 : constraints.maxHeight,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDE8FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.task_alt_rounded,
                      color: purpleColor,
                      size: 25,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.55),
                      fontSize: 11.5,
                      height: 1.22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showCompletedOrderBottomSheet(Ordersdetailsmodel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.88,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE9F8EF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.task_alt_rounded,
                            color: Colors.green.shade700,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                capitalizeText(
                                  order.typeOfWork ?? "Completed Order",
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                "Order completed successfully",
                                style: TextStyle(
                                  color: primaryColor.withOpacity(0.55),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    bottomSheetRow(
                      Icons.description_outlined,
                      "Pages",
                      "${order.userFilePageCount ?? -1}",
                    ),
                    bottomSheetRow(
                      Icons.currency_rupee_rounded,
                      "Earning",
                      "₹${((order.totalOrderAmount ?? 0) - (order.platformFeeAmount ?? 0)).toString()}",
                    ),
                    bottomSheetRow(
                      Icons.language_rounded,
                      "Language",
                      order.languageSelectedChips ?? "Not Selected",
                    ),
                    bottomSheetRow(
                      Icons.water_drop_outlined,
                      "Ink",
                      order.selectedInkColor ?? "Blue",
                    ),
                    bottomSheetRow(
                      Icons.calendar_month_rounded,
                      "Deadline",
                      order.selectedDeadLineUrgency ?? "Not Selected",
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.done_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text("Done"),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: purpleColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget bottomSheetRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: purpleColor,
            size: 18,
          ),

          const SizedBox(width: 9),

          SizedBox(
            width: 74,
            child: Text(
              label,
              style: TextStyle(
                color: primaryColor.withOpacity(0.55),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getCompletedData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final token = await user.getIdToken(true);

    final url = Uri.parse(
      "${apiConfig.baseUrl}/api/writer_side/orders/Completed",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        var item = jsonDecode(response.body);

        setState(() {
          orders.clear();

          for (var data in item) {
            var order = Ordersdetailsmodel.fromJson(data);
            orders.add(order);
          }

          applyFilters();

          isLoading = false;
        });

        print(response.body);
        print(orders.length);
      } else {
        setState(() {
          isLoading = false;
        });

        print("Completed orders failed: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print("Completed orders error: $e");
    }
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
}