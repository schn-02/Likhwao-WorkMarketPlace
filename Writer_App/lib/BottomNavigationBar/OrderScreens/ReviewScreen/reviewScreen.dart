import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/InProgressOrderScreens/OrderWorkingScreen.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/ReviewScreen/viewSubmissionScreen.dart';

class reviewScreen extends StatefulWidget {
  const reviewScreen({super.key});

  @override
  State<reviewScreen> createState() => _reviewScreenState();
}

class _reviewScreenState extends State<reviewScreen> {
  Stream<QuerySnapshot>? orderStream;

  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  String selectedReviewFilter = "All";
  String selectedDeadlineFilter = "All";

  final List<String> reviewFilters = [
    "All",
    "Review",
    "Changes",
    "Disputed",
  ];



  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);

  final Color reviewBg = const Color(0xFFFFF7E6);
  final Color reviewColor = const Color(0xFFFF9800);
  final Color reviewText = const Color(0xFFB76A00);

  final Color changeBg = const Color(0xFFFFF2F4);
  final Color changeColor = const Color(0xFFE84D5B);
  final Color changeText = const Color(0xFFC73542);

  final Color disputeBg = const Color(0xFFFFF0F0);
  final Color disputeColor = const Color(0xFFE53935);
  final Color disputeText = const Color(0xFFB71C1C);

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
        .where("status", whereIn: ["REVIEW", "REQUEST_CHANGES" ,"DISPUTED"])
        .where("writerFirebaseUid", isEqualTo: uid)
        .snapshots();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool isDisputedOrder(Map<String, dynamic> data) {
    final String orderStatus =
        data['status']?.toString().toUpperCase() ?? "";

    final String orderStatus2 =
        data['orderStatus']?.toString().toUpperCase() ?? "";

    final String writerAssignmentStatus =
        data['writerAssignmentStatus']?.toString().toUpperCase() ?? "";

    final String disputeStatus =
        data['disputeStatus']?.toString().toUpperCase() ?? "";

    return orderStatus == "DISPUTED" ||
        orderStatus2 == "DISPUTED" ||
        writerAssignmentStatus == "DISPUTED" ||
        disputeStatus == "OPEN" ||
        disputeStatus == "ADMIN_REVIEWING";
  }

  bool isRequestChangesOrder(Map<String, dynamic> data) {
    String orderStatus = data['status']?.toString() ?? "REVIEW";

    String latestSubmissionStatus =
        data['latestSubmissionStatus']?.toString() ?? orderStatus;

    return orderStatus == "REQUEST_CHANGES" ||
        latestSubmissionStatus == "CHANGES_REQUESTED";
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

    final String latestSubmissionStatus =
        data['latestSubmissionStatus']?.toString().toLowerCase() ?? "";

    final String changeRequestText =
        data['latestSubmissionChangeRequestText']?.toString().toLowerCase() ??
            data['latestChangeRequestText']?.toString().toLowerCase() ??
            data['changeRequestText']?.toString().toLowerCase() ??
            "";

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
        latestSubmissionStatus.contains(query) ||
        changeRequestText.contains(query);
  }

  bool checkReviewFilter(Map<String, dynamic> data) {
    if (selectedReviewFilter == "All") {
      return true;
    }

    final bool isRequestChanges = isRequestChangesOrder(data);
    final bool isDisputed = isDisputedOrder(data);

    if (selectedReviewFilter == "Review") {
      return !isRequestChanges && !isDisputed;
    }

    if (selectedReviewFilter == "Changes") {
      return isRequestChanges && !isDisputed;
    }

    if (selectedReviewFilter == "Disputed") {
      return isDisputed;
    }

    return true;
  }


  List<QueryDocumentSnapshot> applyFilters(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final bool searchMatched = checkSearchFilter(data);
      final bool reviewMatched = checkReviewFilter(data);

      return searchMatched && reviewMatched ;
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
                    title: "No review orders",
                    message: "Submitted work and change requests will appear here.",
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

                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Orderworkingscreen(
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
                      hintText: "Search review orders...",
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
              itemCount: reviewFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final filter = reviewFilters[index];
                final bool isSelected = selectedReviewFilter == filter;

                return filterChipLayout(
                  title: filter,
                  icon: getReviewFilterIcon(filter),
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      selectedReviewFilter = filter;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 7),


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

  IconData getReviewFilterIcon(String filter) {
    switch (filter.toLowerCase()) {
      case "review":
        return Icons.hourglass_top_rounded;
      case "changes":
        return Icons.edit_note_rounded;
      case "disputed":
        return Icons.report_problem_rounded;
      default:
        return Icons.filter_alt_rounded;
    }
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
                Icons.rate_review_outlined,
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

  Widget sampleLayoutOfOrderDetails(Map<String, dynamic> data) {
    String typeOfWork = data['typeOfWork']?.toString() ?? "Not Get";
    String filePageCount = data['filePageCount']?.toString() ?? "-1";
    String totalOrderAmount = data['totalOrderAmount']?.toString() ?? "-1";

    String selectedLanguage =
        data['selectedLanguage']?.toString() ?? "Not Selected";

    String deadline = data['deadline']?.toString() ?? " ";

    String selectedInkColor = data['InkColor']?.toString() ??
        data['selectedInkColor']?.toString() ??
        "Blue";

    String selectedNotebookType = data['NotebookType']?.toString() ??
        data['selectedNotebook']?.toString() ??
        "Single Line";

    bool isRequestChanges = isRequestChangesOrder(data);
    bool isDisputed = isDisputedOrder(data);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: isDisputed
            ? disputeBg
            : isRequestChanges
            ? changeBg
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDisputed
              ? disputeColor.withOpacity(0.22)
              : isRequestChanges
              ? changeColor.withOpacity(0.18)
              : Colors.grey.withOpacity(0.09),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDisputed
                ? disputeColor.withOpacity(0.05)
                : isRequestChanges
                ? changeColor.withOpacity(0.04)
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
              isRequestChanges,
              isDisputed,
            ),

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
                        isRequestChanges,
                        isDisputed,
                      ),
                      const SizedBox(height: 7),
                      orderSmallInfoRow(
                        Icons.calendar_month_rounded,
                        "Deadline",
                        formatDate(deadline),
                        isRequestChanges,
                        isDisputed,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 49,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: isDisputed
                      ? disputeColor.withOpacity(0.12)
                      : isRequestChanges
                      ? changeColor.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.13),
                ),
                Expanded(
                  child: Column(
                    children: [
                      orderSmallInfoRow(
                        Icons.water_drop_outlined,
                        "Ink",
                        selectedInkColor,
                        isRequestChanges,
                        isDisputed,
                      ),
                      const SizedBox(height: 7),
                      orderSmallInfoRow(
                        Icons.menu_book_rounded,
                        "Notebook",
                        selectedNotebookType,
                        isRequestChanges,
                        isDisputed,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            reviewPendingLayout(isRequestChanges, isDisputed, data),

            const SizedBox(height: 9),

            Divider(
              height: 1,
              color: isRequestChanges
                  ? changeColor.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.13),
            ),

            const SizedBox(height: 8),

            bottomCardActionLayout(data),
          ],
        ),
      ),
    );
  }

  Widget orderCardTopLayout(
      String typeOfWork,
      String filePageCount,
      String totalOrderAmount,
      bool isRequestChanges,
      bool isDisputed,
      ) {
    final int amount = int.tryParse(totalOrderAmount.toString()) ?? 0;
    final int writerEarning = (amount - 10).clamp(0, 999999);

    final Color activeTextColor = isDisputed
        ? disputeText
        : isRequestChanges
        ? changeText
        : primaryColor;

    final Color activeIconColor = isDisputed
        ? disputeColor
        : isRequestChanges
        ? changeText
        : purpleColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 39,
          width: 39,
          decoration: BoxDecoration(
            color: isDisputed
                ? disputeColor.withOpacity(0.10)
                : isRequestChanges
                ? changeColor.withOpacity(0.10)
                : const Color(0xFFEDE8FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDisputed
                ? Icons.report_problem_rounded
                : isRequestChanges
                ? Icons.edit_note_rounded
                : Icons.assignment_rounded,
            color: activeIconColor,
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
                  color: activeTextColor,
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
                    isDisputed
                        ? disputeColor.withOpacity(0.08)
                        : isRequestChanges
                        ? changeColor.withOpacity(0.09)
                        : const Color(0xFFEAF3FF),
                    isDisputed
                        ? disputeText
                        : isRequestChanges
                        ? changeText
                        : Colors.blue.shade700,
                  ),
                  smallChipLayout(
                    "₹$writerEarning",
                    isDisputed
                        ? disputeColor.withOpacity(0.08)
                        : isRequestChanges
                        ? changeColor.withOpacity(0.09)
                        : const Color(0xFFE9F8EF),
                    isDisputed
                        ? disputeText
                        : isRequestChanges
                        ? changeText
                        : Colors.green.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        statusChipLayout(isRequestChanges, isDisputed),
      ],
    );
  }

  Widget reviewPendingLayout(
      bool isRequestChanges,
      bool isDisputed,
      Map<String, dynamic> data,
      ) {
    String changeTextValue =
        data['latestSubmissionChangeRequestText']?.toString() ??
            data['latestChangeRequestText']?.toString() ??
            data['changeRequestText']?.toString() ??
            "User requested changes in your submitted work.";

    String disputeMessage =
        data['statusLabel']?.toString() ??
            "User has raised a dispute. Admin will review and contact you soon.";

    final Color activeBgColor = isDisputed
        ? disputeColor.withOpacity(0.08)
        : isRequestChanges
        ? changeColor.withOpacity(0.08)
        : reviewColor.withOpacity(0.10);

    final Color activeBorderColor = isDisputed
        ? disputeColor.withOpacity(0.16)
        : isRequestChanges
        ? changeColor.withOpacity(0.16)
        : reviewColor.withOpacity(0.18);

    final Color activeIconBgColor = isDisputed
        ? disputeColor.withOpacity(0.12)
        : isRequestChanges
        ? changeColor.withOpacity(0.12)
        : reviewColor.withOpacity(0.13);

    final Color activeTextColor = isDisputed
        ? disputeText
        : isRequestChanges
        ? changeText
        : reviewText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: activeBgColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: activeBorderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 26,
            width: 26,
            decoration: BoxDecoration(
              color: activeIconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDisputed
                  ? Icons.admin_panel_settings_rounded
                  : isRequestChanges
                  ? Icons.edit_note_rounded
                  : Icons.hourglass_top_rounded,
              color: activeTextColor,
              size: 15,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              isDisputed
                  ? disputeMessage
                  : isRequestChanges
                  ? changeTextValue
                  : "Submitted • Waiting for user review",
              maxLines: isDisputed || isRequestChanges ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: activeTextColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                height: 1.18,
              ),
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
      bool isRequestChanges,
      bool isDisputed,
      ) {
    final Color activeTextColor = isDisputed
        ? disputeText
        : isRequestChanges
        ? changeText
        : primaryColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: activeTextColor.withOpacity(0.62),
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
                  color: activeTextColor.withOpacity(0.56),
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
                  color: activeTextColor,
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

  Widget statusChipLayout(bool isRequestChanges, bool isDisputed) {
    final Color activeColor = isDisputed
        ? disputeColor
        : isRequestChanges
        ? changeColor
        : reviewColor;

    final Color activeTextColor = isDisputed
        ? disputeText
        : isRequestChanges
        ? changeText
        : reviewText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: activeColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: activeColor.withOpacity(0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDisputed
                ? Icons.report_problem_rounded
                : isRequestChanges
                ? Icons.edit_note_rounded
                : Icons.hourglass_top_rounded,
            color: activeTextColor,
            size: 11,
          ),
          const SizedBox(width: 3),
          Text(
            isDisputed
                ? "Disputed"
                : isRequestChanges
                ? "Changes"
                : "Review",
            style: TextStyle(
              color: activeTextColor,
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

  Widget bottomCardActionLayout(Map<String, dynamic> data) {
    bool isRequestChanges = isRequestChangesOrder(data);
    bool isDisputed = isDisputedOrder(data);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 37,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => viewSubmissionScreen(
                      orderId: data['orderId'],
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.visibility_outlined,
                size: 15,
              ),
              label: const Text("View"),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDisputed ? disputeText : purpleColor,
                side: BorderSide(
                  color: isDisputed
                      ? disputeColor.withOpacity(0.48)
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
              onPressed: isDisputed
                  ? null
                  : () {
                if (isRequestChanges) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Orderworkingscreen(
                        orderId: data['orderId'],
                      ),
                    ),
                  );
                } else {
                  print("Review pending button clicked");
                }
              },
              icon: Icon(
                isDisputed
                    ? Icons.admin_panel_settings_rounded
                    : isRequestChanges
                    ? Icons.upload_file_rounded
                    : Icons.schedule_rounded,
                color: isDisputed
                    ? disputeText
                    : isRequestChanges
                    ? Colors.white
                    : reviewText,
                size: 15,
              ),
              label: Text(
                isDisputed
                    ? "Admin Review"
                    : isRequestChanges
                    ? "Upload"
                    : "Pending",
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                disabledBackgroundColor: disputeColor.withOpacity(0.12),
                disabledForegroundColor: disputeText,
                backgroundColor: isRequestChanges
                    ? changeColor
                    : reviewColor.withOpacity(0.14),
                foregroundColor: isRequestChanges ? Colors.white : reviewText,
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