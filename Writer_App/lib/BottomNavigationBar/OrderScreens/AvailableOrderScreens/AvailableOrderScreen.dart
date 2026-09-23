import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:likho/BottomNavigationBar/OrderScreens/AvailableOrderScreens/OrderDetailsScreen.dart';
import 'package:likho/Model/OrdersDetailsModel.dart';

class Availableorderscreen extends StatefulWidget {
  const Availableorderscreen({super.key});

  @override
  State<Availableorderscreen> createState() => _AvailableorderscreenState();
}

class _AvailableorderscreenState extends State<Availableorderscreen> {
  Stream<QuerySnapshot>? orderStream;

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

  @override
  void initState() {
    super.initState();

    orderStream = FirebaseFirestore.instance
        .collection("orders")
        .where("status", isEqualTo: "FINDING_WRITER")
        .snapshots();
  }

  @override
  void dispose() {
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
    final String inkColor = data['InkColor']?.toString().toLowerCase() ?? "";
    final String notebookType =
        data['NotebookType']?.toString().toLowerCase() ?? "";
    final String requirement =
        data['WriterSuggestionText']?.toString().toLowerCase() ?? "";
    final String urgency = data['urgency']?.toString().toLowerCase() ?? "";

    return orderId.contains(query) ||
        typeOfWork.contains(query) ||
        filePageCount.contains(query) ||
        totalOrderAmount.contains(query) ||
        selectedLanguage.contains(query) ||
        deadline.contains(query) ||
        inkColor.contains(query) ||
        notebookType.contains(query) ||
        requirement.contains(query) ||
        urgency.contains(query);
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

  List<QueryDocumentSnapshot> applyFilters(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final bool searchMatched = checkSearchFilter(data);
      final bool deadlineMatched = checkDeadlineFilter(data);

      return searchMatched && deadlineMatched;
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
                  print("ERROR: ${snapshot.error}");
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
                    title: "No orders available",
                    message:
                    "New user requirements will appear here when users search for writers.",
                  );
                }

                final docs = applyFilters(snapshot.data!.docs);

                if (docs.isEmpty) {
                  return noOrderLayout(
                    title: "No matching orders",
                    message:
                    "Try changing your search text or deadline filter.",
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 82),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(
                              orderId: data['orderId'],
                            ),
                          ),
                        );
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
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.grey.withOpacity(0.16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.028),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: primaryColor.withOpacity(0.45),
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
                      hintText: "Search order, work, language...",
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
            height: 34,
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
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? purpleColor : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? purpleColor
                            : purpleColor.withOpacity(0.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.025),
                          blurRadius: 7,
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
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : purpleColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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

  Widget sampleLayoutOfOrderDetails(Map<String, dynamic> data) {
    String typeOfWork = data['typeOfWork']?.toString() ?? "Assignment";

    String filePageCount = data['filePageCount']?.toString() ?? "0";

    String totalOrderAmount = data['totalOrderAmount']?.toString() ?? "0";

    String selectedLanguage =
        data['selectedLanguage']?.toString() ?? "Not Selected";

    String deadline = data['deadline']?.toString() ?? "Not Selected";

    String inkColor = data['InkColor']?.toString() ?? "Not Added";

    String notebookType = data['NotebookType']?.toString() ?? "Not Added";

    String requirement = data['WriterSuggestionText']?.toString() ??
        "View full details to check user requirements.";

    String urgency = data['urgency']?.toString() ?? "Normal";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            orderCardTopLayout(
              typeOfWork,
              filePageCount,
              totalOrderAmount,
              urgency,
            ),

            const SizedBox(height: 11),

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
                      ),
                      const SizedBox(height: 9),
                      orderSmallInfoRow(
                        Icons.calendar_month_rounded,
                        "Deadline",
                        formatDate(deadline),
                      ),
                      const SizedBox(height: 9),
                      orderSmallInfoRow(
                        Icons.menu_book_rounded,
                        "Notebook",
                        notebookType,
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 82,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 9),
                  color: Colors.grey.withOpacity(0.14),
                ),

                Expanded(
                  child: Column(
                    children: [
                      orderSmallInfoRow(
                        Icons.water_drop_outlined,
                        "Ink Color",
                        inkColor,
                      ),
                      const SizedBox(height: 9),
                      requirementPreviewLayout(requirement),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 11),

            Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.13),
            ),

            const SizedBox(height: 9),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(
                              orderId: data['orderId'],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 16,
                      ),
                      label: const Text("View"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: purpleColor,
                        side: BorderSide(
                          color: purpleColor.withOpacity(0.50),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(
                              orderId: data['orderId'],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text("Accept"),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: purpleColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
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

  Widget orderCardTopLayout(
      String typeOfWork,
      String filePageCount,
      String totalOrderAmount,
      String urgency,
      ) {
    final int amount = int.tryParse(totalOrderAmount.toString()) ?? 0;
    final int writerEarning = (amount - 10).clamp(0, 999999);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: const BoxDecoration(
            color: Color(0xFFEDE8FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.assignment_rounded,
            color: purpleColor,
            size: 23,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                capitalizeText(typeOfWork),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  smallChipLayout(
                    "$filePageCount Page${filePageCount == "1" ? "" : "s"}",
                    const Color(0xFFEAF3FF),
                    Colors.blue.shade700,
                  ),
                  const SizedBox(width: 6),
                  smallChipLayout(
                    "₹$writerEarning",
                    const Color(0xFFE9F8EF),
                    Colors.green.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 7),

        urgencyChipLayout(urgency),
      ],
    );
  }

  Widget orderSmallInfoRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: primaryColor.withOpacity(0.60),
          size: 16,
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.50),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget requirementPreviewLayout(String requirement) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.format_list_bulleted_rounded,
          color: primaryColor.withOpacity(0.60),
          size: 16,
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Requirement",
                style: TextStyle(
                  color: primaryColor.withOpacity(0.50),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                requirement,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.86),
                  fontSize: 11.5,
                  height: 1.18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget smallChipLayout(
      String text,
      Color bgColor,
      Color textColor,
      ) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget urgencyChipLayout(String urgency) {
    String urgencyLower = urgency.toLowerCase();

    Color bgColor = const Color(0xFFEAF3FF);
    Color textColor = Colors.blue.shade700;
    IconData icon = Icons.schedule_rounded;
    String title = "Normal";

    if (urgencyLower.contains("fast")) {
      bgColor = const Color(0xFFFFE9EC);
      textColor = Colors.red.shade600;
      icon = Icons.flash_on_rounded;
      title = "Fast";
    } else if (urgencyLower.contains("urgent")) {
      bgColor = const Color(0xFFFFF4DE);
      textColor = Colors.orange.shade700;
      icon = Icons.local_fire_department_rounded;
      title = "Urgent";
    } else if (urgencyLower.contains("normal")) {
      title = "Normal";
    } else {
      title = urgency.trim().isEmpty ? "Normal" : urgency;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 13,
          ),
          const SizedBox(width: 3),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
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
              height: 68,
              width: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE8FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                color: purpleColor,
                size: 34,
              ),
            ),

            const SizedBox(height: 14),

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
                height: 1.32,
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