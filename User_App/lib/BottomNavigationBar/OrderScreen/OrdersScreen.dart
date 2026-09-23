import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:likhwao/FeedbackScreen/FeedbackScreen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../ApiConfig/apiConfig.dart';
import '../../Model/CreateOrderResponse.dart';
import '../../Model/WriterWorkModel.dart';
import '../../SplashScreens/PaymentSuccessSplash.dart';
import '../InboxScreens/WorkSummary.dart';
import 'OrderDetailsScreen.dart';

class Ordersscreen extends StatefulWidget {
  const Ordersscreen({super.key});

  @override
  State<Ordersscreen> createState() => _OrdersscreenState();
}

class _OrdersscreenState extends State<Ordersscreen> {
  @override
  void initState() {
    super.initState();

    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  int selectedIndex = 1;
  bool isLoading = false;
  late Razorpay razorpay;

  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  final List<String> tabs = ["All", "Active", "Review", "Pending", "Done"];

  final Color bgColor = const Color(0xFF020B2D);
  final Color cardColor = const Color(0xFF07143D);
  final Color innerCardColor = const Color(0xFF101B4D);
  final Color orangeColor = const Color(0xffFF6A00);
  final Color purpleColor = const Color(0xFF7B3FF2);
  final Color successColor = const Color(0xff01B920);
  final Color findingColor = const Color(0xFFB58CFF);

  @override
  void dispose() {
    searchController.dispose();
    razorpay.clear();
    super.dispose();
  }

  Stream<QuerySnapshot> getOrdersStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection("orders")
        .where("userFirebaseUid", isEqualTo: user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 55,
        backgroundColor: bgColor,
        centerTitle: false,
        title: const Text(
          "MY ORDERS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 7, bottom: 7),
          child: Container(
            decoration: BoxDecoration(
              color: innerCardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: const Icon(
                Icons.receipt_long_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              Positioned(
                right: 13,
                top: 12,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: orangeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: _searchBox(),
            ),
            const SizedBox(height: 9),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _statusTabs(),
            ),
            const SizedBox(height: 9),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getOrdersStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print("ORDERS FIREBASE ERROR: ${snapshot.error}");

                    return Center(
                      child: Text(
                        "Something went wrong",
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: orangeColor),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return emptyOrdersLayout();
                  }

                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                  docs = filterOrdersByTab(docs);
                  docs = filterOrdersBySearch(docs);

                  docs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;

                    final aTime = getDateTimeFromAny(
                      aData["updatedAtTimestamp"] ??
                          aData["createdAtTimestamp"] ??
                          aData["createdAt"],
                    );

                    final bTime = getDateTimeFromAny(
                      bData["updatedAtTimestamp"] ??
                          bData["createdAtTimestamp"] ??
                          bData["createdAt"],
                    );

                    return bTime.compareTo(aTime);
                  });

                  if (docs.isEmpty) {
                    return emptyOrdersLayout();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: sampleOrderLayout(data),
                      );
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

  Widget _searchBox() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: Colors.white.withOpacity(0.65),
                  size: 22,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w700,
                    ),
                    cursorColor: orangeColor,
                    decoration: InputDecoration(
                      hintText: "Search order ID or subject...",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 12.8,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                if (searchText.isNotEmpty)
                  InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () {
                      searchController.clear();

                      setState(() {
                        searchText = "";
                      });
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(0.62),
                      size: 19,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 9),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            print("Filter clicked");
          },
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: Colors.white.withOpacity(0.78),
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusTabs() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final bool isSelected = selectedIndex == index;

          return InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: isSelected ? purpleColor : cardColor,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFB58CFF)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Center(
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: Colors.white.withOpacity(isSelected ? 1 : 0.80),
                    fontSize: 11.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<QueryDocumentSnapshot> filterOrdersByTab(
      List<QueryDocumentSnapshot> docs,
      ) {
    if (selectedIndex == 0) {
      return docs;
    }

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = getOrderStatus(data);
      final paymentPending = isPaymentPending(data);
      final findingWriter = isFindingWriter(data);

      if (selectedIndex == 1) {
        return findingWriter ||
            (!paymentPending &&
                (status == "ACCEPTED" || status == "IN_PROGRESS"));
      }

      if (selectedIndex == 2) {
        return !paymentPending &&
            (status == "REVIEW" ||
                status == "UNDER_REVIEW" ||
                status == "REQUEST_CHANGES");
      }

      if (selectedIndex == 3) {
        return !findingWriter && paymentPending;
      }

      if (selectedIndex == 4) {
        return !paymentPending && status == "COMPLETED";
      }

      return true;
    }).toList();
  }

  List<QueryDocumentSnapshot> filterOrdersBySearch(
      List<QueryDocumentSnapshot> docs,
      ) {
    if (searchText.isEmpty) {
      return docs;
    }

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final orderId = getValueFromData(data, ["orderId"], "").toLowerCase();
      final typeOfWork = getValueFromData(
        data,
        ["typeOfWork"],
        "",
      ).toLowerCase();
      final orderTitle = getValueFromData(
        data,
        ["orderTitle"],
        "",
      ).toLowerCase();
      final fileName = getValueFromData(
        data,
        ["userFileName", "fileName"],
        "",
      ).toLowerCase();

      return orderId.contains(searchText) ||
          typeOfWork.contains(searchText) ||
          orderTitle.contains(searchText) ||
          fileName.contains(searchText);
    }).toList();
  }

  Widget emptyOrdersLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 78,
              width: 78,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFFB58CFF),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              getEmptyTitle(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              "Your orders will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getEmptyTitle() {
    if (selectedIndex == 1) {
      return "No active orders";
    }

    if (selectedIndex == 2) {
      return "No review orders";
    }

    if (selectedIndex == 3) {
      return "No pending payments";
    }

    if (selectedIndex == 4) {
      return "No completed orders";
    }

    return "No orders found";
  }

  Widget sampleOrderLayout(Map<String, dynamic> data) {
    final String orderId = getValueFromData(data, ["orderId"], "N/A");

    final String title = getValueFromData(
      data,
      ["typeOfWork"],
      "Handwritten Work",
    );

    final String rawWriterName = getValueFromData(
      data,
      ["writerName"],
      "Not Assigned",
    );

    final String pages =
        "${getValueFromData(data, ["userFilePageCount", "filePageCount"], "0")} Pages";

    final String deadline = formatDateOnly(
      data["deadline"] ?? data["selectedDate"],
      "No deadline",
    );

    final String amount =
        "₹${getValueFromData(data, ["totalOrderAmount"], "0")}";

    final String status = getOrderStatus(data);
    final bool findingWriter = isFindingWriter(data);
    final bool paymentPending = isPaymentPending(data);
    final int progressPercent = getProgressPercent(data);

    final Color statusColor = findingWriter
        ? findingColor
        : paymentPending
        ? orangeColor
        : getStatusColor(status);

    final int activeStep = getActiveStepFromData(data);

    final IconData icon = getOrderIcon(
      getValueFromData(data, ["typeOfWork"], ""),
    );

    final String firstButton = getFirstButtonText(data);
    final IconData firstButtonIcon = getFirstButtonIcon(data);

    final String secondButton = getSecondButtonText(data);
    final IconData secondButtonIcon = getSecondButtonIcon(data);

    final String writerName = findingWriter ? "Finding writer" : rawWriterName;

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(orderData: data),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: findingWriter
                ? findingColor.withOpacity(0.35)
                : paymentPending
                ? orangeColor.withOpacity(0.28)
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: findingWriter
                  ? findingColor.withOpacity(0.08)
                  : paymentPending
                  ? orangeColor.withOpacity(0.08)
                  : Colors.black.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 43,
                  width: 43,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: findingWriter
                          ? const [Color(0xFF7B3FF2), Color(0xFF4B1AB8)]
                          : paymentPending
                          ? const [Color(0xffFF7A00), Color(0xffFF4D00)]
                          : const [Color(0xFF7B3FF2), Color(0xFF4B1AB8)],
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    findingWriter
                        ? Icons.person_search_rounded
                        : paymentPending
                        ? Icons.payment_rounded
                        : icon,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Order #$orderId",
                        style: const TextStyle(
                          color: Color(0xFFB58CFF),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _infoChip(Icons.person_outline_rounded, writerName),
                          _infoChip(Icons.description_outlined, pages),
                          _infoChip(Icons.calendar_month_rounded, deadline),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 112),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: statusColor.withOpacity(0.65),
                        ),
                      ),
                      child: Text(
                        findingWriter
                            ? "FINDING"
                            : paymentPending
                            ? "PAY NOW"
                            : cleanStatus(status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      amount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (findingWriter) ...[
              const SizedBox(height: 12),
              findingWriterMessage(),
            ] else if (paymentPending) ...[
              const SizedBox(height: 12),
              paymentPendingMessage(),
            ],

            const SizedBox(height: 14),
            _orderProgress(activeStep, findingWriter: findingWriter),
            const SizedBox(height: 9),

            if (!paymentPending && !findingWriter)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "$progressPercent% Done",
                  style: TextStyle(
                    color: getProgressColor(progressPercent),
                    fontSize: 11.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _orangeButton(
                    text: firstButton,
                    icon: firstButtonIcon,
                    usePurple: findingWriter,
                    onTap: () async {
                      if (isLoading) {
                        return;
                      }

                      if (paymentPending && !findingWriter) {
                        print("Pay Now clicked: $orderId");

                        final int orderIdInt = int.tryParse(orderId) ?? 0;

                        if (orderIdInt == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Invalid order ID")),
                          );
                          return;
                        }

                        onPayNowClicked(orderIdInt);
                      } else if (firstButton == "View Work") {
                        final work = createWriterWorkModelFromFirebase(data);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Worksummary(work: work),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(orderData: data),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: isFeedbackGiven(data)
                      ? _ratingButton(
                    rating: getFeedbackRating(data),
                    onTap: () {
                      print("Already rated: ${getFeedbackRating(data)}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "You already rated this writer ${getFeedbackRating(data)} star",
                          ),
                        ),
                      );
                    },
                  )
                      : _outlineButton(
                    text: secondButton,
                    icon: secondButtonIcon,
                    borderColor: findingWriter ? findingColor : orangeColor,
                    onTap: () {
                      if (findingWriter) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(orderData: data),
                          ),
                        );
                        return;
                      }

                      if (paymentPending) {
                        print("Payment details clicked: $orderId");

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(orderData: data),
                          ),
                        );

                        return;
                      }

                      if (status == "COMPLETED" ||
                          secondButton == "Feedback") {
                        print("Feedback clicked: $orderId");
                        openFeedbackScreen(data);
                        return;
                      }

                      print("$secondButton clicked: $orderId");
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void openFeedbackScreen(Map<String, dynamic> data) {
    final int orderId = parseIntValue(
      getValueFromData(data, ["orderId"], "0"),
    );

    final int userId = parseIntValue(
      getValueFromData(data, ["userId", "sqlUserId"], "0"),
    );

    final int writerId = parseIntValue(
      getValueFromData(
        data,
        ["writerId", "writerSqlId", "assignedWriterId"],
        "0",
      ),
    );

    final String writerName = getValueFromData(
      data,
      ["writerName"],
      "Writer",
    );

    if (orderId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order ID missing")),
      );
      return;
    }

    if (writerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Writer ID missing")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackScreen(
          orderId: orderId,
          userId: userId,
          writerId: writerId,
          writerName: writerName,
        ),
      ),
    );
  }

  Widget findingWriterMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: findingColor.withOpacity(0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: findingColor.withOpacity(0.32)),
      ),
      child: Row(
        children: [
          Container(
            height: 31,
            width: 31,
            decoration: BoxDecoration(
              color: findingColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_search_rounded,
              color: findingColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Finding a suitable writer. Payment will open after writer assignment.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.86),
                fontSize: 12.2,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentPendingMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: orangeColor.withOpacity(0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: orangeColor.withOpacity(0.32)),
      ),
      child: Row(
        children: [
          Container(
            height: 31,
            width: 31,
            decoration: BoxDecoration(
              color: orangeColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_clock_rounded, color: orangeColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Pay to start writer work.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.86),
                fontSize: 12.2,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.55), size: 13),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.62),
            fontSize: 10.8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _orderProgress(int activeStep, {bool findingWriter = false}) {
    final List<String> steps = [
      "Req",
      "Writer",
      "Pay",
      "Work",
      "Review",
      "Done",
    ];

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final bool completed = index + 1 < activeStep;
            final bool current = index + 1 == activeStep;
            final bool lockedPayment = findingWriter && index == 2;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2.2,
                      color: index == 0
                          ? Colors.transparent
                          : (completed || current)
                          ? successColor
                          : Colors.white.withOpacity(0.15),
                    ),
                  ),

                  Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      color: completed
                          ? successColor
                          : current
                          ? const Color(0xffFFB000)
                          : innerCardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: completed || current
                            ? Colors.transparent
                            : lockedPayment
                            ? findingColor.withOpacity(0.45)
                            : Colors.white.withOpacity(0.30),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(
                      completed
                          ? Icons.check_rounded
                          : lockedPayment
                          ? Icons.lock_rounded
                          : current
                          ? Icons.circle
                          : Icons.circle_outlined,
                      color: Colors.white,
                      size: current ? 8 : 13,
                    ),
                  ),

                  Expanded(
                    child: Container(
                      height: 2.2,
                      color: index == steps.length - 1
                          ? Colors.transparent
                          : index + 1 < activeStep
                          ? successColor
                          : Colors.white.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 6),

        Row(
          children: steps
              .map(
                (step) => Expanded(
              child: Text(
                step,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }
  Widget _orangeButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    bool usePurple = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: usePurple
                ? const [Color(0xFF7B3FF2), Color(0xFF4B1AB8)]
                : const [Color(0xffFF7A00), Color(0xffFF4D00)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (usePurple ? purpleColor : orangeColor).withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.2,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlineButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color? borderColor,
  }) {
    final Color color = borderColor ?? orangeColor;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.85)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.2,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, color: Colors.white, size: 15),
          ],
        ),
      ),
    );
  }

  Widget _ratingButton({
    required String rating,
    required VoidCallback onTap,
  }) {
    final int ratingInt = int.tryParse(rating) ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xffFFB000).withOpacity(0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xffFFB000).withOpacity(0.85),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffFFB000).withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_rounded,
              color: Color(0xffFFB000),
              size: 16,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final bool filled = index < ratingInt;

                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xffFFB000),
                    size: 14,
                  );
                }),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              rating.isEmpty ? "Rated" : rating,
              style: const TextStyle(
                color: Color(0xffFFB000),
                fontSize: 12.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isFindingWriter(Map<String, dynamic> data) {
    final status = getOrderStatus(data).replaceAll(" ", "_");

    return status == "FINDING_WRITER" ||
        status == "FINDING" ||
        status == "FINDING_WRITER_STATUS";
  }

  bool isPaymentPaid(Map<String, dynamic> data) {
    final paymentStatus = getValueFromData(
      data,
      ["paymentStatus"],
      "",
    ).toUpperCase();

    final orderStatus = getValueFromData(
      data,
      ["orderStatus"],
      "",
    ).toUpperCase();

    final paymentRequired = getValueFromData(
      data,
      ["paymentRequired"],
      "",
    ).toLowerCase();

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
    if (isFindingWriter(data)) {
      return false;
    }

    if (isPaymentPaid(data)) {
      return false;
    }

    final paymentStatus = getValueFromData(
      data,
      ["paymentStatus"],
      "",
    ).toUpperCase();

    final orderStatus = getValueFromData(
      data,
      ["orderStatus"],
      "",
    ).toUpperCase();

    final paymentRequired = getValueFromData(
      data,
      ["paymentRequired"],
      "",
    ).toLowerCase();

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

    return false;
  }

  int getProgressPercent(Map<String, dynamic> data) {
    final status = getOrderStatus(data);

    if (isFindingWriter(data)) {
      return 0;
    }

    if (isPaymentPending(data)) {
      return 0;
    }

    if (status == "ACCEPTED") {
      return 10;
    }

    if (status == "IN_PROGRESS") {
      return 40;
    }

    if (status == "REVIEW" ||
        status == "UNDER_REVIEW" ||
        status == "REQUEST_CHANGES") {
      return 90;
    }

    if (status == "COMPLETED") {
      return 100;
    }

    return 0;
  }

  Color getProgressColor(int percent) {
    if (percent >= 100) {
      return const Color(0xff7CFF9B);
    }

    if (percent >= 25) {
      return const Color(0xffFFB000);
    }

    return const Color(0xFFB58CFF);
  }

  int getActiveStepFromData(Map<String, dynamic> data) {
    final status = getOrderStatus(data).replaceAll(" ", "_");

    if (status == "COMPLETED") {
      return 6;
    }

    if (status == "REVIEW" ||
        status == "UNDER_REVIEW" ||
        status == "REQUEST_CHANGES") {
      return 5;
    }

    if (status == "IN_PROGRESS" || status == "WORK_STARTED") {
      return 4;
    }

    if (isFindingWriter(data)) {
      return 2;
    }

    if (status == "ACCEPTED" && isPaymentPending(data)) {
      return 3;
    }

    if (status == "ACCEPTED" && !isPaymentPending(data)) {
      return 4;
    }

    if (isPaymentPending(data)) {
      return 3;
    }

    return 2;
  }

  String getOrderStatus(Map<String, dynamic> data) {
    return getValueFromData(
      data,
      ["status", "writerAssignmentStatus"],
      "UNKNOWN",
    ).toUpperCase();
  }

  String cleanStatus(String status) {
    final upperStatus = status.toUpperCase().replaceAll(" ", "_");

    if (upperStatus == "PAYMENT_PENDING") {
      return "PENDING";
    }

    if (upperStatus == "UNDER_REVIEW" || upperStatus == "REVIEW") {
      return "REVIEW";
    }

    if (upperStatus == "IN_PROGRESS") {
      return "ACTIVE";
    }

    if (upperStatus == "FINDING_WRITER" || upperStatus == "FINDING") {
      return "FINDING";
    }

    if (upperStatus == "REQUEST_CHANGES") {
      return "CHANGES";
    }

    if (upperStatus == "COMPLETED") {
      return "DONE";
    }

    if (upperStatus == "ACCEPTED") {
      return "ACCEPTED";
    }

    return upperStatus.replaceAll("_", " ");
  }

  Color getStatusColor(String status) {
    final upperStatus = status.toUpperCase().replaceAll(" ", "_");

    if (upperStatus == "IN_PROGRESS" || upperStatus == "ACCEPTED") {
      return const Color(0xff1DB954);
    }

    if (upperStatus == "REVIEW" || upperStatus == "UNDER_REVIEW") {
      return const Color(0xff2F80ED);
    }

    if (upperStatus == "REQUEST_CHANGES") {
      return const Color(0xffFFB000);
    }

    if (upperStatus == "COMPLETED") {
      return const Color(0xff01B920);
    }

    if (upperStatus == "FINDING_WRITER" || upperStatus == "FINDING") {
      return const Color(0xFFB58CFF);
    }

    return Colors.white70;
  }

  String getFirstButtonText(Map<String, dynamic> data) {
    final status = getOrderStatus(data);

    if (isFindingWriter(data)) {
      return "View Details";
    }

    if (isPaymentPending(data)) {
      return "Pay Now";
    }

    if (status == "REVIEW" || status == "UNDER_REVIEW") {
      return "View Work";
    }

    if (status == "REQUEST_CHANGES") {
      return "ON CHANGES";
    }

    if (status == "COMPLETED") {
      return "View Order";
    }

    return "View Details";
  }

  String getSecondButtonText(Map<String, dynamic> data) {
    final status = getOrderStatus(data);

    if (isFindingWriter(data)) {
      return "Finding Writer";
    }

    if (isPaymentPending(data)) {
      return "Details";
    }

    if (status == "COMPLETED") {
      if (isFeedbackGiven(data)) {
        final String rating = getFeedbackRating(data);

        if (rating.isNotEmpty) {
          return "Rated $rating★";
        }

        return "Feedback Given";
      }

      return "Feedback";
    }

    return "${getProgressPercent(data)}% Done";
  }

  IconData getFirstButtonIcon(Map<String, dynamic> data) {
    final status = getOrderStatus(data);

    if (isFindingWriter(data)) {
      return Icons.arrow_forward_ios_rounded;
    }

    if (isPaymentPending(data)) {
      return Icons.payment_rounded;
    }

    if (status == "REVIEW" || status == "UNDER_REVIEW") {
      return Icons.remove_red_eye_rounded;
    }

    if (status == "REQUEST_CHANGES") {
      return Icons.hourglass_top_rounded;
    }

    if (status == "COMPLETED") {
      return Icons.visibility_rounded;
    }

    return Icons.arrow_forward_ios_rounded;
  }

  IconData getSecondButtonIcon(Map<String, dynamic> data) {
    final status = getOrderStatus(data);

    if (isFindingWriter(data)) {
      return Icons.person_search_rounded;
    }

    if (isPaymentPending(data)) {
      return Icons.info_outline_rounded;
    }

    if (status == "COMPLETED") {
      if (isFeedbackGiven(data)) {
        return Icons.star_rounded;
      }

      return Icons.reviews_rounded;
    }

    return Icons.percent_rounded;
  }

  IconData getOrderIcon(String typeOfWork) {
    final lower = typeOfWork.toLowerCase();

    if (lower.contains("practical") || lower.contains("lab")) {
      return Icons.science_rounded;
    }

    if (lower.contains("exam")) {
      return Icons.school_rounded;
    }

    if (lower.contains("notes")) {
      return Icons.menu_book_rounded;
    }

    if (lower.contains("assignment")) {
      return Icons.assignment_rounded;
    }

    return Icons.description_rounded;
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

  String formatDateOnly(dynamic value, String fallback) {
    try {
      if (value == null) {
        return fallback;
      }

      if (value is Timestamp) {
        return DateFormat("dd MMM").format(value.toDate());
      }

      if (value is DateTime) {
        return DateFormat("dd MMM").format(value);
      }

      final text = value.toString().trim();

      if (text.isEmpty || text == "null") {
        return fallback;
      }

      final dateTime = DateTime.tryParse(text);

      if (dateTime == null) {
        return text;
      }

      return DateFormat("dd MMM").format(dateTime);
    } catch (e) {
      return fallback;
    }
  }

  DateTime getDateTimeFromAny(dynamic value) {
    try {
      if (value == null) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }

      return DateTime.tryParse(value.toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    } catch (e) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  void onPayNowClicked(int orderId) async {
    try {
      setState(() {
        isLoading = true;
      });

      CreateOrderResponse orderResponse = await createPaymentOrderApi(orderId);

      openCheckout(orderResponse.razorpayOrderId, orderResponse.amount);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
      print("ERROR:-$e");
    }
  }

  void openCheckout(String orderId, int amount) {
    var options = {
      'key': const String.fromEnvironment('RAZORPAY_KEY_ID'),
      'order_id': orderId,
      'amount': amount,
      'currency': 'INR',
      'name': 'Likhwao',
      'description': 'Notebook Writing Order',
      'prefill': {
        'contact': '9784329023',
        'email': 'robbinhood846@gmail.com',
      },
      'theme': {'color': '#3399cc'},
    };

    razorpay.open(options);
  }

  Future<CreateOrderResponse> createPaymentOrderApi(int orderId) async {
    final url = Uri.parse(
      "${apiConfig.baseUrl}/api/user_side/orders/createPayment?orderId=$orderId",
    );

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final token = await user.getIdToken();

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      print("Successfully data stored");

      var data = jsonDecode(response.body);

      return CreateOrderResponse.fromJson(data);
    } else {
      throw Exception("Order creation failed: ${response.body}");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      isLoading = false;
    });

    try {
      final url = Uri.parse(
        "${apiConfig.baseUrl}/api/user_side/orders/verifyPayment",
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      final token = await user.getIdToken();

      final apiResponse = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "razorpayPaymentId": response.paymentId,
          "razorpayOrderId": response.orderId,
          "razorpaySignature": response.signature,
        }),
      );

      print("Status code: ${apiResponse.statusCode}");
      print("Response body: ${apiResponse.body}");

      if (apiResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Verified ✅")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PaymentSuccessSplash()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment verification failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error during verification")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      isLoading = false;
    });

    debugPrint("Payment Failed: ${response.message}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Failed")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      isLoading = false;
    });

    debugPrint("External Wallet: ${response.walletName}");
  }

  Writerworkmodel createWriterWorkModelFromFirebase(Map<String, dynamic> data) {
    final int orderId = parseIntValue(getValueFromData(data, ["orderId"], "0"));

    final int latestWriterWorkId = parseIntValue(
      getValueFromData(data, ["latestWriterWorkId", "writerWorkId"], "0"),
    );

    final int latestFilePageCount = parseIntValue(
      getValueFromData(data, ["latestSubmissionPageCount"], "0"),
    );

    final int userFilePageCount = parseIntValue(
      getValueFromData(data, ["filePageCount", "userFilePageCount"], "0"),
    );

    final int totalOrderAmount = parseIntValue(
      getValueFromData(data, ["totalOrderAmount"], "0"),
    );

    final int platformFeeAmount = parseIntValue(
      getValueFromData(data, ["platformFeeAmount"], "0"),
    );

    final int deliveryChargesAmount = parseIntValue(
      getValueFromData(data, ["deliveryChargesAmount"], "0"),
    );

    final int noteBookChargesAmount = parseIntValue(
      getValueFromData(data, ["noteBookChargesAmount"], "0"),
    );

    final int userId = parseIntValue(getValueFromData(data, ["userId"], "0"));

    final String status = getValueFromData(
      data,
      ["status", "latestSubmissionStatus"],
      "REVIEW",
    );

    return Writerworkmodel(
      writerWorkId: latestWriterWorkId,
      UserOrderId: orderId,
      fileName: getValueFromData(
        data,
        ["latestSubmissionFileName"],
        "Uploaded work file",
      ),
      fileUrl: getValueFromData(data, ["latestSubmissionFilePath"], ""),
      fileSize: parseIntValue(
        getValueFromData(data, ["latestSubmissionFileSize"], "0"),
      ),
      filePageCount: latestFilePageCount,
      orderCompletedAtReview: parseDateValue(
        data["latestSubmissionUploadedAt"],
      ),
      selectedDate: parseDateValue(data["deadline"] ?? data["selectedDate"]),
      orderCreatedAt: parseDateValue(
        data["createdAt"] ?? data["orderCreatedAt"],
      ),
      orderCompletedAt: parseDateValue(
        data["completedAt"] ?? data["orderCompletedAt"],
      ),
      orderStatus: data["orderStatus"]?.toString(),
      typeOfWork: getValueFromData(data, ["typeOfWork"], "Handwritten Work"),
      writerAssignmentStatus: status,
      totalOrderAmount: totalOrderAmount,
      selectedDeadLineUrgency:
      data["selectedDeadLineUrgency"]?.toString() ??
          data["urgency"]?.toString(),
      userId: userId,
      writerFirebaseUid: data["writerFirebaseUid"]?.toString(),
      selectedInkColor:
      data["InkColor"]?.toString() ?? data["selectedInkColor"]?.toString(),
      selectedNotebook:
      data["NotebookType"]?.toString() ??
          data["selectedNotebook"]?.toString(),
      deliveryChargesAmount: deliveryChargesAmount,
      platformFeeAmount: platformFeeAmount,
      noteBookChargesAmount: noteBookChargesAmount,
      razorpayOrderId: data["razorpayOrderId"]?.toString(),
      paymentId: data["paymentId"]?.toString(),
      paymentBank: data["paymentBank"]?.toString(),
      paymentStatus: data["paymentStatus"]?.toString(),
      paymentMethod: data["paymentMethod"]?.toString(),
      refundId: data["refundId"]?.toString(),
      refundStatus: data["refundStatus"]?.toString(),
      userFileName: data["fileName"]?.toString(),
      userFilePageCount: userFilePageCount,
      userFileSize: parseIntValue(
        getValueFromData(data, ["fileSize", "userFileSize"], "0"),
      ),
      writerSuggestionText: data["latestSubmissionWriterNote"]?.toString(),
      userSuggestionText:
      data["WriterSuggestionText"]?.toString() ??
          data["writerSuggestionText"]?.toString(),
    );
  }

  int parseIntValue(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  DateTime? parseDateValue(dynamic value) {
    try {
      if (value == null) {
        return null;
      }

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }

      String text = value.toString().trim();

      if (text.isEmpty || text == "null") {
        return null;
      }

      return DateTime.tryParse(text);
    } catch (e) {
      print("Date parse error: $e");
      return null;
    }
  }

  bool isFeedbackGiven(Map<String, dynamic> data) {
    final String feedbackGiven = getValueFromData(
      data,
      ["feedbackGiven"],
      "false",
    ).toLowerCase();

    final String feedbackStatus = getValueFromData(
      data,
      ["feedbackStatus"],
      "",
    ).toUpperCase();

    if (feedbackGiven == "true") {
      return true;
    }

    if (feedbackStatus == "SUBMITTED") {
      return true;
    }

    return false;
  }

  String getFeedbackRating(Map<String, dynamic> data) {
    final String rating = getValueFromData(
      data,
      ["writerRating", "feedbackRating", "rating"],
      "0",
    );

    if (rating == "0" || rating.isEmpty || rating == "null") {
      return "";
    }

    return rating;
  }
}