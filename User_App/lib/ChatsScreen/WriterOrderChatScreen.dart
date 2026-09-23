import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Model/WriterChatListModel.dart';
import 'AdminUserChatScreen.dart';
import 'ChatDetailScreen.dart';

class WriterOrderChatScreen extends StatefulWidget {
  final List<Writerchatlistmodel> writerOrders;

  const WriterOrderChatScreen({
    super.key,
    required this.writerOrders,
  });

  @override
  State<WriterOrderChatScreen> createState() => _WriterOrderChatScreenState();
}

class _WriterOrderChatScreenState extends State<WriterOrderChatScreen> {
  final TextEditingController searchController = TextEditingController();

  final Color bgColor = const Color(0xFF020B2D);
  final Color cardColor = const Color(0xFF07143D);
  final Color innerCardColor = const Color(0xFF101B4D);
  final Color purpleColor = const Color(0xFF8D5CFF);
  final Color lightPurple = const Color(0xFFB58CFF);
  final Color orangeColor = const Color(0xffFF6A00);
  final Color whatsappGreen = const Color(0xFF22C55E);
  final Color adminBlue = const Color(0xFF3B82F6);

  String searchText = "";

  final Map<String, int> adminUnreadByOrderId = {};
  final Set<String> orderIdsWithAdminChat = {};
  bool adminDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchAdminChatData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ── Fetch admin chat data ─────────────────────────────────────────────────

  Future<void> _fetchAdminChatData() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || widget.writerOrders.isEmpty) {
      if (mounted) setState(() => adminDataLoaded = true);
      return;
    }

    final String currentUserChatId = "USER_$uid";

    try {
      final Map<String, int> tempUnread = {};
      final Set<String> tempExisting = {};

      for (final order in widget.writerOrders) {
        final String docId = "ADMIN_USER_${order.orderId}";

        // Saare messages fetch karo — no isRead filter
        final snapshot = await FirebaseFirestore.instance
            .collection("admin_user_chats")
            .doc(docId)
            .collection("messages")
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Chat exist karti hai — hamesha list mein show karo
          tempExisting.add(order.orderId.toString());

          // Unread count karo
          int unreadCount = 0;
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final String receiverId = data["receiverId"]?.toString() ?? "";
            final bool isRead = data["isRead"] == true;
            if (receiverId == currentUserChatId && !isRead) {
              unreadCount++;
            }
          }

          if (unreadCount > 0) {
            tempUnread[order.orderId.toString()] = unreadCount;
          }
        }
      }

      if (mounted) {
        setState(() {
          adminUnreadByOrderId
            ..clear()
            ..addAll(tempUnread);
          orderIdsWithAdminChat
            ..clear()
            ..addAll(tempExisting);
          adminDataLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("ADMIN CHAT FETCH ERROR: $e");
      if (mounted) setState(() => adminDataLoaded = true);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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

    final writerName = widget.writerOrders.isNotEmpty
        ? widget.writerOrders.first.writerName?.toString() ?? "Writer"
        : "Writer";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        toolbarHeight: 46,
        leadingWidth: 42,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8, top: 7, bottom: 7),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: innerCardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
        title: const Text(
          "ORDER CHATS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup("messages")
              .snapshots(),
          builder: (context, snapshot) {
            final Map<String, int> unreadCountByOrderId = {};

            if (snapshot.hasData) {
              for (final doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final String receiverId = data["receiverId"]?.toString() ?? "";
                final bool isRead = data["isRead"] == true;
                final String? chatId = doc.reference.parent.parent?.id;
                final String? parentCollection =
                    doc.reference.parent.parent?.parent.id;

                if (parentCollection != "chats") continue;

                if (chatId != null &&
                    chatId.isNotEmpty &&
                    receiverId == currentUserChatId &&
                    !isRead) {
                  unreadCountByOrderId[chatId] =
                      (unreadCountByOrderId[chatId] ?? 0) + 1;
                }
              }
            }

            final filteredOrders = getFilteredOrders();

            filteredOrders.sort((a, b) {
              final int aUnread =
                  unreadCountByOrderId[a.orderId.toString()] ?? 0;
              final int bUnread =
                  unreadCountByOrderId[b.orderId.toString()] ?? 0;
              if (aUnread > 0 && bUnread == 0) return -1;
              if (aUnread == 0 && bUnread > 0) return 1;
              return (b.orderId?.toString() ?? "")
                  .compareTo(a.orderId?.toString() ?? "");
            });

            final int unreadOrderCount = widget.writerOrders.where((order) {
              return (unreadCountByOrderId[order.orderId.toString()] ?? 0) > 0;
            }).length;

            final int unreadMessageCount = unreadCountByOrderId.values
                .fold(0, (prev, curr) => prev + curr);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
                  child: _writerHeader(
                    writerName,
                    unreadOrderCount: unreadOrderCount,
                    unreadMessageCount: unreadMessageCount,
                  ),
                ),

                // ✅ FIX: orderIdsWithAdminChat.isNotEmpty se check — unread pe nahi
                if (adminDataLoaded && orderIdsWithAdminChat.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 0),
                    child: _adminBanner(uid: uid),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  child: _searchBox(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 7),
                  child: _smallSectionHeader(
                    count: filteredOrders.length,
                    unreadCount: unreadOrderCount,
                  ),
                ),
                Expanded(
                  child: filteredOrders.isEmpty
                      ? _emptyOrders()
                      : ListView.builder(
                    padding:
                    const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final String orderId = order.orderId.toString();
                      final int unreadCount =
                          unreadCountByOrderId[orderId] ?? 0;
                      final int adminUnread =
                          adminUnreadByOrderId[orderId] ?? 0;
                      final bool isUnread = unreadCount > 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    Chatdetailscreen(order: order),
                              ),
                            );
                            if (mounted) {
                              setState(() {});
                              _fetchAdminChatData();
                            }
                          },
                          child: _orderChatCard(
                            order,
                            unreadCount: unreadCount,
                            isUnread: isUnread,
                            adminUnread: adminUnread,
                            uid: uid,
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

  // ── Admin Banner ──────────────────────────────────────────────────────────

  Widget _adminBanner({required String uid}) {
    final int totalUnread =
    adminUnreadByOrderId.values.fold(0, (prev, curr) => prev + curr);
    final bool hasUnread = totalUnread > 0;

    // Orders jinki admin chat exist karti hai
    final List<Writerchatlistmodel> adminChatOrders = widget.writerOrders
        .where((o) => orderIdsWithAdminChat.contains(o.orderId.toString()))
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F4A),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: adminBlue.withOpacity(hasUnread ? 0.55 : 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: adminBlue.withOpacity(0.18),
                  border:
                  Border.all(color: adminBlue.withOpacity(0.40)),
                ),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: adminBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Admin Support",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasUnread
                          ? "$totalUnread unread message${totalUnread == 1 ? "" : "s"} from admin"
                          : "${adminChatOrders.length} active support chat${adminChatOrders.length == 1 ? "" : "s"}",
                      style: TextStyle(
                        color: hasUnread
                            ? adminBlue
                            : Colors.white.withOpacity(0.55),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasUnread)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: adminBlue.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                    border:
                    Border.all(color: adminBlue.withOpacity(0.40)),
                  ),
                  child: Text(
                    "$totalUnread New",
                    style: TextStyle(
                      color: adminBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // ✅ FIX: orderIdsWithAdminChat wale saare orders dikhao
          ...adminChatOrders.map((order) {
            final int unread =
                adminUnreadByOrderId[order.orderId.toString()] ?? 0;
            final bool orderHasUnread = unread > 0;

            return Padding(
              padding: const EdgeInsets.only(top: 5),
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminUserChatScreen(
                        userFirebaseUid: uid,
                        userName: order.writerName ?? "User",
                        orderId: order.orderId ?? 0,
                      ),
                    ),
                  );
                  if (mounted) _fetchAdminChatData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: orderHasUnread
                        ? adminBlue.withOpacity(0.14)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: orderHasUnread
                          ? adminBlue.withOpacity(0.40)
                          : Colors.white.withOpacity(0.10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        orderHasUnread
                            ? Icons.mark_chat_unread_rounded
                            : Icons.chat_bubble_outline_rounded,
                        color: orderHasUnread
                            ? adminBlue
                            : Colors.white.withOpacity(0.55),
                        size: 14,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          "#Order ${order.orderId} — Admin Chat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: orderHasUnread
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (orderHasUnread) _adminUnreadBadge(unread),
                      if (!orderHasUnread)
                        Text(
                          "Open",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: orderHasUnread
                            ? adminBlue
                            : Colors.white.withOpacity(0.30),
                        size: 11,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _adminUnreadBadge(int count) {
    return Container(
      height: 18,
      constraints: const BoxConstraints(minWidth: 18),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: adminBlue,
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

  // ── Writer Header ─────────────────────────────────────────────────────────

  Widget _writerHeader(
      String writerName, {
        required int unreadOrderCount,
        required int unreadMessageCount,
      }) {
    final bool hasUnread = unreadMessageCount > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: hasUnread ? const Color(0xFF062F26) : cardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: hasUnread
              ? whatsappGreen.withOpacity(0.35)
              : purpleColor.withOpacity(0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _writerAvatar(writerName, isUnread: hasUnread),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  writerName.trim().isNotEmpty ? writerName : "Writer",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.6,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  hasUnread
                      ? "$unreadMessageCount unread message${unreadMessageCount == 1 ? "" : "s"}"
                      : "${widget.writerOrders.length} order chat${widget.writerOrders.length > 1 ? "s" : ""}",
                  style: TextStyle(
                    color: hasUnread
                        ? whatsappGreen
                        : Colors.white.withOpacity(0.56),
                    fontSize: 10.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: hasUnread
                  ? whatsappGreen.withOpacity(0.13)
                  : purpleColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasUnread
                    ? whatsappGreen.withOpacity(0.28)
                    : purpleColor.withOpacity(0.25),
              ),
            ),
            child: Text(
              hasUnread
                  ? "$unreadOrderCount New"
                  : "${widget.writerOrders.length}",
              style: TextStyle(
                color: hasUnread ? whatsappGreen : lightPurple,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _writerAvatar(String writerName, {required bool isUnread}) {
    final String letter = writerName.trim().isNotEmpty
        ? writerName.trim()[0].toUpperCase()
        : "W";

    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUnread
            ? const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF0F8F4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Color(0xFF8D5CFF), Color(0xFF4B1AB8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────

  Widget _searchBox() {
    return Container(
      height: 37,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded,
              color: Colors.white.withOpacity(0.58), size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: TextField(
              controller: searchController,
              cursorColor: orangeColor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.6,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: "Search order id or message...",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.40),
                  fontSize: 11.4,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) =>
                  setState(() => searchText = value.trim().toLowerCase()),
            ),
          ),
          if (searchText.isNotEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                searchController.clear();
                setState(() => searchText = "");
              },
              child: Icon(Icons.close_rounded,
                  color: Colors.white.withOpacity(0.60), size: 16),
            ),
        ],
      ),
    );
  }

  Widget _smallSectionHeader({
    required int count,
    required int unreadCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            unreadCount > 0 ? "Unread Order Chats" : "Active Order Chats",
            style: TextStyle(
              color: unreadCount > 0 ? whatsappGreen : Colors.white,
              fontSize: 12.4,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          unreadCount > 0 ? "$unreadCount unread" : "$count found",
          style: TextStyle(
            color: unreadCount > 0
                ? whatsappGreen
                : Colors.white.withOpacity(0.48),
            fontSize: 10.4,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  List<Writerchatlistmodel> getFilteredOrders() {
    if (searchText.isEmpty) {
      return List<Writerchatlistmodel>.from(widget.writerOrders);
    }

    return widget.writerOrders.where((order) {
      final orderId = order.orderId?.toString().toLowerCase() ?? "";
      final message =
          order.writerLastMessage?.toString().toLowerCase() ?? "";
      final writerName = order.writerName?.toString().toLowerCase() ?? "";

      return orderId.contains(searchText) ||
          message.contains(searchText) ||
          writerName.contains(searchText);
    }).toList();
  }

  Widget _emptyOrders() {
    final bool searching = searchText.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: purpleColor.withOpacity(0.25)),
              ),
              child: Icon(
                searching ? Icons.search_off_rounded : Icons.chat_rounded,
                color: lightPurple,
                size: 28,
              ),
            ),
            const SizedBox(height: 11),
            Text(
              searching ? "No matching order chats" : "No order chats",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              searching
                  ? "Try searching with order id or message."
                  : "Order-wise chats will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.52),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Order Chat Card ───────────────────────────────────────────────────────

  Widget _orderChatCard(
      Writerchatlistmodel list, {
        required int unreadCount,
        required bool isUnread,
        required int adminUnread,
        required String uid,
      }) {
    final String lastMessage =
    list.writerLastMessage?.toString().trim().isNotEmpty == true
        ? list.writerLastMessage.toString()
        : "Open chat for this order";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.5),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFF062F26) : cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? whatsappGreen.withOpacity(0.35)
              : Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isUnread ? 0.20 : 0.12),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: isUnread
                      ? whatsappGreen.withOpacity(0.14)
                      : innerCardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isUnread
                        ? whatsappGreen.withOpacity(0.30)
                        : purpleColor.withOpacity(0.24),
                  ),
                ),
                child: Icon(
                  isUnread
                      ? Icons.mark_chat_unread_rounded
                      : Icons.receipt_long_rounded,
                  color: isUnread ? whatsappGreen : lightPurple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "#Order ${list.orderId}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: isUnread
                                  ? FontWeight.w900
                                  : FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (isUnread) _writerUnreadBadge(unreadCount),
                      ],
                    ),
                    const SizedBox(height: 2.5),
                    Text(
                      isUnread ? "New message from writer" : lastMessage,
                      style: TextStyle(
                        color: isUnread
                            ? Colors.white.withOpacity(0.90)
                            : Colors.white.withOpacity(0.56),
                        fontSize: 10.8,
                        fontWeight: isUnread
                            ? FontWeight.w900
                            : FontWeight.w600,
                        height: 1.20,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4.5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: isUnread ? whatsappGreen : orangeColor,
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isUnread ? "Open unread chat" : "Open Chat",
                          style: TextStyle(
                            color:
                            isUnread ? whatsappGreen : orangeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isUnread
                    ? whatsappGreen
                    : Colors.white.withOpacity(0.40),
                size: 11,
              ),
            ],
          ),

          // Admin unread strip inside card — sirf unread hone par
          if (adminUnread > 0) ...[
            const SizedBox(height: 7),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminUserChatScreen(
                      userFirebaseUid: uid,
                      userName: list.writerName ?? "User",
                      orderId: list.orderId ?? 0,
                    ),
                  ),
                );
                if (mounted) _fetchAdminChatData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: adminBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border:
                  Border.all(color: adminBlue.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings_rounded,
                        color: adminBlue, size: 13),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "$adminUnread new message${adminUnread == 1 ? "" : "s"} from Admin",
                        style: TextStyle(
                          color: adminBlue,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _adminUnreadBadge(adminUnread),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _writerUnreadBadge(int count) {
    return Container(
      height: 18,
      constraints: const BoxConstraints(minWidth: 18),
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
}