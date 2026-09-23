import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:likho/ApiConfig/apiConfig.dart';
import 'package:likho/ChatsScreen/ChatDetailScreen.dart';
import 'package:likho/ChatsScreen/ChatListScreen.dart';
import 'package:likho/Model/UserChatListModel.dart';

class Inboxscreen extends StatefulWidget {
  const Inboxscreen({super.key});

  @override
  State<Inboxscreen> createState() => _InboxscreenState();
}

class _InboxscreenState extends State<Inboxscreen> {
  final TextEditingController searchController = TextEditingController();

  List<Userchatlistmodel> chatList = [];
  Map<int, List<Userchatlistmodel>> groupedData = {};

  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);
  final Color whatsappGreen = const Color(0xFF22C55E);

  bool isLoading = true;
  String selectedFilter = "All";
  String searchText = "";

  @override
  void initState() {
    super.initState();
    fetchChatListDataApi();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            "Anonymous Writer",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    final String currentWriterChatId = "WRITER_$uid";

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup("messages")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint("WRITER INBOX CHAT QUERY ERROR: ${snapshot.error}");
            }

            final Map<String, int> unreadCountByOrderId = {};

            if (snapshot.hasData) {
              for (final doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;

                final String receiverId = data["receiverId"]?.toString() ?? "";
                final bool isRead = data["isRead"] == true;
                final String? chatId = doc.reference.parent.parent?.id;

                if (chatId != null &&
                    chatId.isNotEmpty &&
                    receiverId == currentWriterChatId &&
                    !isRead) {
                  unreadCountByOrderId[chatId] =
                      (unreadCountByOrderId[chatId] ?? 0) + 1;
                }
              }
            }

            final List<List<Userchatlistmodel>> allGroups =
            groupedData.values.toList();

            final List<List<Userchatlistmodel>> filteredGroups =
            getFilteredGroups(
              allGroups: allGroups,
              unreadCountByOrderId: unreadCountByOrderId,
            );

            filteredGroups.sort((a, b) {
              final int aUnread = getGroupUnreadCount(
                a,
                unreadCountByOrderId,
              );
              final int bUnread = getGroupUnreadCount(
                b,
                unreadCountByOrderId,
              );

              if (aUnread > 0 && bUnread == 0) return -1;
              if (aUnread == 0 && bUnread > 0) return 1;

              final String aName = a.first.userName?.toLowerCase() ?? "";
              final String bName = b.first.userName?.toLowerCase() ?? "";

              return aName.compareTo(bName);
            });

            final int totalUnreadOrders = unreadCountByOrderId.length;
            final int totalUnreadMessages = unreadCountByOrderId.values.fold(
              0,
                  (previous, current) => previous + current,
            );

            final int changesCount = chatList.where((item) {
              return (item.orderStatus ?? "").toUpperCase().contains("REQUEST");
            }).length;

            final int reviewCount = chatList.where((item) {
              return (item.orderStatus ?? "").toUpperCase() == "REVIEW";
            }).length;

            return Column(
              children: [
                inboxTopHeader(
                  unreadMessages: totalUnreadMessages,
                ),
                inboxStatsLayout(
                  totalUsers: allGroups.length,
                  totalOrders: chatList.length,
                  unreadOrders: totalUnreadOrders,
                  changesCount: changesCount,
                  reviewCount: reviewCount,
                ),
                inboxFilterLayout(),
                Expanded(
                  child: isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: purpleColor,
                      strokeWidth: 2.2,
                    ),
                  )
                      : filteredGroups.isEmpty
                      ? noInboxDataLayout()
                      : ListView.builder(
                    padding:
                    const EdgeInsets.fromLTRB(10, 2, 10, 24),
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final List<Userchatlistmodel> orders =
                      filteredGroups[index];

                      final int unreadCount = getGroupUnreadCount(
                        orders,
                        unreadCountByOrderId,
                      );

                      final bool isUnread = unreadCount > 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () async {
                            if (orders.length == 1) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Chatdetailscreen(
                                        order: orders[0],
                                      ),
                                ),
                              );
                            } else {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Chatlistscreen(
                                        order: orders,
                                      ),
                                ),
                              );
                            }

                            if (mounted) {
                              setState(() {});
                            }
                          },
                          child: sampleLayoutChatList(
                            orders,
                            unreadCount: unreadCount,
                            isUnread: isUnread,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<List<Userchatlistmodel>> getFilteredGroups({
    required List<List<Userchatlistmodel>> allGroups,
    required Map<String, int> unreadCountByOrderId,
  }) {
    List<List<Userchatlistmodel>> result = allGroups;

    if (selectedFilter == "Unread") {
      result = result.where((group) {
        return getGroupUnreadCount(group, unreadCountByOrderId) > 0;
      }).toList();
    } else if (selectedFilter == "Changes") {
      result = result.where((group) {
        return group.any((item) {
          return (item.orderStatus ?? "").toUpperCase().contains("REQUEST");
        });
      }).toList();
    } else if (selectedFilter == "Review") {
      result = result.where((group) {
        return group.any((item) {
          return (item.orderStatus ?? "").toUpperCase() == "REVIEW";
        });
      }).toList();
    }

    if (searchText.trim().isNotEmpty) {
      final String query = searchText.trim().toLowerCase();

      result = result.where((group) {
        final Userchatlistmodel first = group.first;

        final String userName = first.userName?.toLowerCase() ?? "";
        final String userNumber = first.userNumber?.toLowerCase() ?? "";

        final bool orderMatch = group.any((item) {
          final String orderId = item.orderId?.toString().toLowerCase() ?? "";
          final String status = item.orderStatus?.toLowerCase() ?? "";
          final String name = item.userName?.toLowerCase() ?? "";
          final String number = item.userNumber?.toLowerCase() ?? "";

          return orderId.contains(query) ||
              status.contains(query) ||
              name.contains(query) ||
              number.contains(query);
        });

        return userName.contains(query) ||
            userNumber.contains(query) ||
            orderMatch;
      }).toList();
    }

    return result;
  }

  int getGroupUnreadCount(
      List<Userchatlistmodel> orders,
      Map<String, int> unreadCountByOrderId,
      ) {
    int count = 0;

    for (final order in orders) {
      final String orderId = order.orderId.toString();
      count += unreadCountByOrderId[orderId] ?? 0;
    }

    return count;
  }

  Widget inboxTopHeader({
    required int unreadMessages,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(17),
          bottomRight: Radius.circular(17),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Inbox",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unreadMessages > 0
                      ? "$unreadMessages unread message${unreadMessages == 1 ? "" : "s"}"
                      : "Manage users and order chats",
                  style: TextStyle(
                    color: unreadMessages > 0
                        ? whatsappGreen
                        : Colors.white.withOpacity(0.72),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              if (unreadMessages > 0)
                Positioned(
                  right: -1,
                  top: -1,
                  child: unreadBadge(
                    unreadMessages,
                    small: true,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget inboxStatsLayout({
    required int totalUsers,
    required int totalOrders,
    required int unreadOrders,
    required int changesCount,
    required int reviewCount,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 9, 10, 6),
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          inboxStatItem(
            icon: Icons.people_alt_rounded,
            iconColor: purpleColor,
            iconBgColor: const Color(0xFFEDE8FF),
            title: "Users",
            value: "$totalUsers",
          ),
          inboxDivider(),
          inboxStatItem(
            icon: Icons.mark_chat_unread_rounded,
            iconColor: whatsappGreen,
            iconBgColor: whatsappGreen.withOpacity(0.12),
            title: "Unread",
            value: "$unreadOrders",
          ),
          inboxDivider(),
          inboxStatItem(
            icon: Icons.edit_note_rounded,
            iconColor: Colors.red.shade600,
            iconBgColor: const Color(0xFFFFE9EC),
            title: "Changes",
            value: "$changesCount",
          ),
          inboxDivider(),
          inboxStatItem(
            icon: Icons.rate_review_rounded,
            iconColor: Colors.orange.shade800,
            iconBgColor: const Color(0xFFFFF2D9),
            title: "Review",
            value: "$reviewCount",
          ),
        ],
      ),
    );
  }

  Widget inboxStatItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 27,
            width: 27,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 15,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.56),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
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

  Widget inboxDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withOpacity(0.16),
    );
  }

  Widget inboxFilterLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
      child: Column(
        children: [
          Row(
            children: [
              filterChipLayout("All"),
              const SizedBox(width: 6),
              filterChipLayout("Unread"),
              const SizedBox(width: 6),
              filterChipLayout("Changes"),
              const SizedBox(width: 6),
              filterChipLayout("Review"),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.grey.withOpacity(0.16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.030),
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
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search users or orders...",
                      hintStyle: TextStyle(
                        color: primaryColor.withOpacity(0.38),
                        fontSize: 11.8,
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
                      color: primaryColor.withOpacity(0.45),
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget filterChipLayout(String title) {
    final bool isSelected = selectedFilter == title;

    Color selectedColor = purpleColor;

    if (title == "Unread") {
      selectedColor = whatsappGreen;
    } else if (title == "Changes") {
      selectedColor = Colors.red.shade600;
    } else if (title == "Review") {
      selectedColor = Colors.orange.shade800;
    }

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            selectedFilter = title;
          });
        },
        child: Container(
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedColor.withOpacity(isSelected ? 1 : 0.22),
            ),
          ),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? Colors.white : primaryColor.withOpacity(0.70),
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget sampleLayoutChatList(
      List<Userchatlistmodel> orders, {
        required int unreadCount,
        required bool isUnread,
      }) {
    if (orders.isEmpty) return const SizedBox();

    final Userchatlistmodel first = orders[0];

    final StatusUi statusUi = getStatusUi(first.orderStatus ?? "");

    String ordersText = "";

    if (orders.length == 1) {
      ordersText = "Order #${orders[0].orderId}";
    } else {
      ordersText = orders
          .take(2)
          .map((e) => "Order #${e.orderId}")
          .join(" • ") +
          (orders.length > 2 ? " • +${orders.length - 2} more" : "");
    }

    return Container(
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF2FFF6) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isUnread
              ? whatsappGreen.withOpacity(0.28)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isUnread ? 0.060 : 0.038),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: isUnread
                        ? whatsappGreen.withOpacity(0.12)
                        : const Color(0xFFEDE8FF),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/user.png",
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: unreadBadge(unreadCount),
                  )
                else if (orders.length > 1)
                  Positioned(
                    right: -3,
                    bottom: -3,
                    child: Container(
                      height: 18,
                      width: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: purpleColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        "${orders.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          first.userName ?? "",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight:
                            isUnread ? FontWeight.w900 : FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isUnread
                            ? "New"
                            : orders.length == 1
                            ? "Chat"
                            : "${orders.length} orders",
                        style: TextStyle(
                          color: isUnread
                              ? whatsappGreen
                              : primaryColor.withOpacity(0.42),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isUnread ? "New message from user" : ordersText,
                    style: TextStyle(
                      color: isUnread
                          ? primaryColor.withOpacity(0.88)
                          : primaryColor.withOpacity(0.62),
                      fontSize: 11,
                      fontWeight: isUnread ? FontWeight.w900 : FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      statusChipLayout(
                        statusUi.bgColor,
                        statusUi.textColor,
                        statusUi.icon,
                        statusUi.text,
                      ),
                      const Spacer(),
                      Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F7FF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isUnread
                                ? whatsappGreen.withOpacity(0.22)
                                : purpleColor.withOpacity(0.14),
                          ),
                        ),
                        child: Icon(
                          orders.length == 1
                              ? Icons.chat_bubble_outline_rounded
                              : Icons.chevron_right_rounded,
                          color: isUnread ? whatsappGreen : purpleColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget unreadBadge(
      int count, {
        bool small = false,
      }) {
    return Container(
      height: small ? 16 : 18,
      constraints: BoxConstraints(
        minWidth: small ? 16 : 18,
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: small ? 4 : 5),
      decoration: BoxDecoration(
        color: whatsappGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        count > 99 ? "99+" : "$count",
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 7 : 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget statusChipLayout(
      Color bgColor,
      Color textColor,
      IconData statusIcon,
      String statusText,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: textColor,
            size: 12,
          ),
          const SizedBox(width: 3),
          Text(
            statusText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  StatusUi getStatusUi(String status) {
    final String upperStatus = status.toUpperCase();

    if (upperStatus == "ACCEPT") {
      return StatusUi(
        bgColor: const Color(0xFFE9F8EF),
        textColor: Colors.green.shade700,
        icon: Icons.check_circle_outline_rounded,
        text: "ACCEPTED",
      );
    } else if (upperStatus == "IN_PROGRESS") {
      return StatusUi(
        bgColor: const Color(0xFFEAF3FF),
        textColor: Colors.blue.shade700,
        icon: Icons.play_circle_outline_rounded,
        text: "IN PROGRESS",
      );
    } else if (upperStatus == "REVIEW") {
      return StatusUi(
        bgColor: const Color(0xFFFFF2D9),
        textColor: Colors.orange.shade800,
        icon: Icons.hourglass_top_rounded,
        text: "REVIEW",
      );
    } else if (upperStatus.contains("REQUEST")) {
      return StatusUi(
        bgColor: const Color(0xFFFFE9EC),
        textColor: Colors.red.shade600,
        icon: Icons.edit_note_rounded,
        text: "REQUEST",
      );
    }

    return StatusUi(
      bgColor: const Color(0xFFEDE8FF),
      textColor: purpleColor,
      icon: Icons.chat_bubble_outline_rounded,
      text: status.isEmpty ? "CHAT" : status,
    );
  }

  Widget noInboxDataLayout() {
    final bool isSearching = searchText.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
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
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.mark_chat_unread_outlined,
                color: purpleColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isSearching ? "No matching chats" : "No chats yet",
              style: TextStyle(
                color: primaryColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? "Try another user name, order id or status."
                  : "Users and order conversations will appear here after payment confirmation or order activity.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor.withOpacity(0.55),
                fontSize: 12.5,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchChatListDataApi() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      return;
    }

    final token = await user.getIdToken(true);

    final url = Uri.parse(
      "${apiConfig.baseUrl}/api/writer_side/chats/userList",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final item = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          chatList.clear();
          groupedData.clear();

          for (var data in item) {
            var list = Userchatlistmodel.fromJson(data);
            chatList.add(list);

            int userId = data['userId'];

            if (!groupedData.containsKey(userId)) {
              groupedData[userId] = [];
            }

            groupedData[userId]!.add(list);
          }

          isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        debugPrint("Chat list failed: ${response.statusCode}");
        debugPrint("Chat list body: ${response.body}");
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint("Chat list error: $e");
    }
  }
}

class StatusUi {
  final Color bgColor;
  final Color textColor;
  final IconData icon;
  final String text;

  StatusUi({
    required this.bgColor,
    required this.textColor,
    required this.icon,
    required this.text,
  });
}