import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../ChatsScreen/WriterOrderChatScreen.dart';
import '../../Model/WriterChatListModel.dart';

class Chatlistscreen extends StatefulWidget {
  final List<Writerchatlistmodel> order;

  final Future<void> Function() onRefresh;

  const Chatlistscreen({
    super.key,
    required this.order,
    required this.onRefresh,
  });

  @override
  State<Chatlistscreen> createState() => _ChatlistscreenState();
}

class _ChatlistscreenState extends State<Chatlistscreen> {
  final TextEditingController searchController = TextEditingController();

  final Color bgColor = const Color(0xFF020B2D);
  final Color cardColor = const Color(0xFF07143D);
  final Color innerCardColor = const Color(0xFF101B4D);
  final Color purpleColor = const Color(0xFF8D5CFF);
  final Color lightPurple = const Color(0xFFB58CFF);
  final Color orangeColor = const Color(0xffFF6A00);
  final Color whatsappGreen = const Color(0xFF22C55E);

  String searchText = "";

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
            "Anonymous User",
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    final String currentUserChatId = "USER_$uid";

    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup("messages")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint("USER CHAT LIST QUERY ERROR: ${snapshot.error}");
            }

            debugPrint("USER UID: $uid");
            debugPrint("USER CHAT ID: $currentUserChatId");
            debugPrint("TOTAL MESSAGE DOCS: ${snapshot.data?.docs.length ?? 0}");

            final Map<String, int> unreadCountByOrderId = {};

            if (snapshot.hasData) {
              for (final doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;

                final String receiverId = data["receiverId"]?.toString() ?? "";
                final bool isRead = data["isRead"] == true;
                final String? chatId = doc.reference.parent.parent?.id;

                if (chatId != null &&
                    chatId.isNotEmpty &&
                    receiverId == currentUserChatId &&
                    !isRead) {
                  unreadCountByOrderId[chatId] =
                      (unreadCountByOrderId[chatId] ?? 0) + 1;
                }
              }
            }

            debugPrint("USER FINAL UNREAD MAP: $unreadCountByOrderId");

            final groupedWriterList = getFilteredGroupedOrders();

            groupedWriterList.sort((a, b) {
              final int aUnread = getGroupUnreadCount(a, unreadCountByOrderId);
              final int bUnread = getGroupUnreadCount(b, unreadCountByOrderId);

              if (aUnread > 0 && bUnread == 0) return -1;
              if (aUnread == 0 && bUnread > 0) return 1;

              final aName = a.first.writerName?.toString().toLowerCase() ?? "";
              final bName = b.first.writerName?.toString().toLowerCase() ?? "";
              return aName.compareTo(bName);
            });

            final int totalUnreadOrders = unreadCountByOrderId.length;
            final int totalUnreadMessages = unreadCountByOrderId.values.fold(
              0,
                  (previous, current) => previous + current,
            );

            return Column(
              children: [
                _topHeader(
                  unreadOrders: totalUnreadOrders,
                  unreadMessages: totalUnreadMessages,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                  child: _searchBox(),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: widget.onRefresh,
                    backgroundColor: bgColor,
                    color: orangeColor,
                    child: groupedWriterList.isEmpty
                        ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: _emptyChatList(),
                        ),
                      ],
                    )
                        : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      itemCount: groupedWriterList.length,
                      itemBuilder: (context, index) {
                        final writerOrders = groupedWriterList[index];
                        final firstOrder = writerOrders.first;

                        final int unreadCount = getGroupUnreadCount(
                          writerOrders,
                          unreadCountByOrderId,
                        );

                        final bool isUnread = unreadCount > 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WriterOrderChatScreen(
                                    writerOrders: writerOrders,
                                  ),
                                ),
                              );

                              if (mounted) {
                                setState(() {});
                              }
                            },
                            child: sampleLayoutChatList(
                              firstOrder,
                              writerOrders,
                              unreadCount: unreadCount,
                              isUnread: isUnread,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
      )
    );
  }

  int getGroupUnreadCount(
      List<Writerchatlistmodel> writerOrders,
      Map<String, int> unreadCountByOrderId,
      ) {
    int count = 0;

    for (final order in writerOrders) {
      final String orderId = order.orderId.toString();
      count += unreadCountByOrderId[orderId] ?? 0;
    }

    return count;
  }

  Widget _topHeader({
    required int unreadOrders,
    required int unreadMessages,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: innerCardColor,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CHATS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  unreadMessages > 0
                      ? "$unreadMessages unread message${unreadMessages == 1 ? "" : "s"}"
                      : "All conversations",
                  style: TextStyle(
                    color: unreadMessages > 0
                        ? whatsappGreen
                        : Colors.white.withOpacity(0.48),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (widget.order.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: unreadOrders > 0
                    ? whatsappGreen.withOpacity(0.12)
                    : purpleColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: unreadOrders > 0
                      ? whatsappGreen.withOpacity(0.35)
                      : purpleColor.withOpacity(0.35),
                ),
              ),
              child: Text(
                unreadOrders > 0
                    ? "$unreadOrders New"
                    : "${widget.order.length} Orders",
                style: TextStyle(
                  color: unreadOrders > 0 ? whatsappGreen : lightPurple,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.62),
            size: 19,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: TextField(
              controller: searchController,
              cursorColor: orangeColor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: "Search writer or order id...",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.42),
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
                color: Colors.white.withOpacity(0.62),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  List<List<Writerchatlistmodel>> getFilteredGroupedOrders() {
    final groupedList = groupOrdersByWriter();

    if (searchText.isEmpty) {
      return groupedList;
    }

    return groupedList.where((writerOrders) {
      final firstOrder = writerOrders.first;

      final writerName = firstOrder.writerName?.toString().toLowerCase() ?? "";
      final lastMessage =
          firstOrder.writerLastMessage?.toString().toLowerCase() ?? "";

      final orderMatched = writerOrders.any((order) {
        final orderId = order.orderId?.toString().toLowerCase() ?? "";
        final message =
            order.writerLastMessage?.toString().toLowerCase() ?? "";
        final name = order.writerName?.toString().toLowerCase() ?? "";

        return orderId.contains(searchText) ||
            message.contains(searchText) ||
            name.contains(searchText);
      });

      return writerName.contains(searchText) ||
          lastMessage.contains(searchText) ||
          orderMatched;
    }).toList();
  }

  List<List<Writerchatlistmodel>> groupOrdersByWriter() {
    final Map<String, List<Writerchatlistmodel>> groupedData = {};

    for (final item in widget.order) {
      final writerName = item.writerName?.toString().trim();

      final writerKey = writerName != null && writerName.isNotEmpty
          ? writerName.toLowerCase()
          : "unknown_writer";

      if (groupedData.containsKey(writerKey)) {
        groupedData[writerKey]!.add(item);
      } else {
        groupedData[writerKey] = [item];
      }
    }

    final list = groupedData.values.toList();

    list.sort((a, b) {
      final aName = a.first.writerName?.toString().toLowerCase() ?? "";
      final bName = b.first.writerName?.toString().toLowerCase() ?? "";
      return aName.compareTo(bName);
    });

    return list;
  }

  Widget _emptyChatList() {
    final bool searching = searchText.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: purpleColor.withOpacity(0.28),
                ),
              ),
              child: Icon(
                searching
                    ? Icons.search_off_rounded
                    : Icons.chat_bubble_outline_rounded,
                color: lightPurple,
                size: 32,
              ),
            ),
            const SizedBox(height: 13),
            Text(
              searching ? "No matching chats" : "No chats yet",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              searching
                  ? "Try searching with writer name or order id."
                  : "Once a writer accepts your order, your chat will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sampleLayoutChatList(
      Writerchatlistmodel list,
      List<Writerchatlistmodel> writerOrders, {
        required int unreadCount,
        required bool isUnread,
      }) {
    final writerName = list.writerName?.toString().trim().isNotEmpty == true
        ? list.writerName.toString()
        : "Writer";

    final lastMessage =
    list.writerLastMessage?.toString().trim().isNotEmpty == true
        ? list.writerLastMessage.toString()
        : "Tap to view order-wise chats";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFF062F26) : cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread
              ? whatsappGreen.withOpacity(0.35)
              : Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isUnread ? 0.22 : 0.16),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _writerAvatar(
            writerName,
            isUnread: isUnread,
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
                        writerName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                          isUnread ? FontWeight.w900 : FontWeight.w800,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (isUnread) unreadBadge(unreadCount),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      color: isUnread ? whatsappGreen : lightPurple,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${writerOrders.length} order chat${writerOrders.length > 1 ? "s" : ""}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isUnread ? whatsappGreen : lightPurple,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  isUnread ? "New message from writer" : lastMessage,
                  style: TextStyle(
                    fontSize: 11.2,
                    fontWeight: isUnread ? FontWeight.w900 : FontWeight.w600,
                    color: isUnread
                        ? Colors.white.withOpacity(0.90)
                        : Colors.white.withOpacity(0.60),
                    height: 1.20,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 7),
                _orderIdLine(
                  writerOrders,
                  isUnread: isUnread,
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: isUnread ? whatsappGreen : Colors.white.withOpacity(0.42),
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget unreadBadge(int count) {
    return Container(
      height: 18,
      constraints: const BoxConstraints(
        minWidth: 18,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: whatsappGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        count > 99 ? "99+" : "$count",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _writerAvatar(
      String writerName, {
        required bool isUnread,
      }) {
    final String firstLetter = writerName.trim().isNotEmpty
        ? writerName.trim()[0].toUpperCase()
        : "W";

    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUnread
            ? const LinearGradient(
          colors: [
            Color(0xFF22C55E),
            Color(0xFF0F8F4A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [
            Color(0xFF8D5CFF),
            Color(0xFF4B1AB8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1.1,
        ),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _orderIdLine(
      List<Writerchatlistmodel> writerOrders, {
        required bool isUnread,
      }) {
    final displayOrders = writerOrders.take(3).toList();
    final remaining = writerOrders.length - displayOrders.length;

    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: [
        ...displayOrders.map((order) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: isUnread
                  ? whatsappGreen.withOpacity(0.12)
                  : innerCardColor,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: isUnread
                    ? whatsappGreen.withOpacity(0.28)
                    : purpleColor.withOpacity(0.28),
              ),
            ),
            child: Text(
              "#${order.orderId}",
              style: TextStyle(
                color: isUnread ? whatsappGreen : lightPurple,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        }),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: orangeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: orangeColor.withOpacity(0.25),
              ),
            ),
            child: Text(
              "+$remaining more",
              style: TextStyle(
                color: orangeColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}