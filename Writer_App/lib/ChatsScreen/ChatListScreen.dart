import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:likho/ChatsScreen/AdminWriterChatScreen.dart';
import 'package:likho/ChatsScreen/ChatDetailScreen.dart';
import 'package:likho/Model/UserChatListModel.dart';

class Chatlistscreen extends StatefulWidget {
  final List<Userchatlistmodel> order;

  const Chatlistscreen({
    super.key,
    required this.order,
  });

  @override
  State<Chatlistscreen> createState() => _ChatlistscreenState();
}

class _ChatlistscreenState extends State<Chatlistscreen> {
  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);
  final Color whatsappGreen = const Color(0xFF22C55E);
  final Color adminBlue = const Color(0xFF3B82F6);

  // ── Admin chat state ──────────────────────────────────────────────────────
  final Map<String, int> adminUnreadByOrderId = {};
  final Set<String> orderIdsWithAdminChat = {};
  bool adminDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchAdminChatData();
  }

  // ── Fetch admin chat data (Future, no stream) ─────────────────────────────

  Future<void> _fetchAdminChatData() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      if (mounted) setState(() => adminDataLoaded = true);
      return;
    }

    final String currentWriterChatId = "WRITER_$uid";

    try {
      final Map<String, int> tempUnread = {};
      final Set<String> tempExisting = {};

      // Is writer ke orders ki IDs
      final Set<String> myOrderIds =
      widget.order.map((o) => o.orderId.toString()).toSet();

      for (final orderId in myOrderIds) {
        final String docId = "ADMIN_WRITER_$orderId";

        final msgSnapshot = await FirebaseFirestore.instance
            .collection("admin_writer_chats")
            .doc(docId)
            .collection("messages")
            .get();

        if (msgSnapshot.docs.isEmpty) continue;

        // Check if any message belongs to this writer
        final bool belongsToWriter = msgSnapshot.docs.any((doc) {
          final data = doc.data();
          final String receiverUid =
              data["receiverFirebaseUid"]?.toString() ?? "";
          final String senderUid =
              data["senderFirebaseUid"]?.toString() ?? "";
          return receiverUid == uid || senderUid == uid;
        });

        if (!belongsToWriter) continue;

        tempExisting.add(orderId);

        // Unread count
        int unreadCount = 0;
        for (final msgDoc in msgSnapshot.docs) {
          final data = msgDoc.data();
          final String receiverId = data["receiverId"]?.toString() ?? "";
          final bool isRead = data["isRead"] == true;
          if (receiverId == currentWriterChatId && !isRead) {
            unreadCount++;
          }
        }

        if (unreadCount > 0) {
          tempUnread[orderId] = unreadCount;
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

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            "Anonymous Writer",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800),
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
              debugPrint("CHAT LIST QUERY ERROR: ${snapshot.error}");
            }

            final Map<String, int> unreadCountByOrderId = {};

            if (snapshot.hasData) {
              for (final doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;

                final String receiverId = data["receiverId"]?.toString() ?? "";
                final bool isRead = data["isRead"] == true;
                final String? chatId = doc.reference.parent.parent?.id;
                final String? parentCollection =
                    doc.reference.parent.parent?.parent.id;

                // ✅ FIX: Sirf "chats" collection — admin_writer_chats skip
                if (parentCollection != "chats") continue;

                if (chatId != null &&
                    chatId.isNotEmpty &&
                    receiverId == currentWriterChatId &&
                    !isRead) {
                  unreadCountByOrderId[chatId] =
                      (unreadCountByOrderId[chatId] ?? 0) + 1;
                }
              }
            }

            final List<Userchatlistmodel> unreadOrders = [];
            final List<Userchatlistmodel> readOrders = [];

            for (final item in widget.order) {
              final String orderId = item.orderId.toString();
              if ((unreadCountByOrderId[orderId] ?? 0) > 0) {
                unreadOrders.add(item);
              } else {
                readOrders.add(item);
              }
            }

            return Column(
              children: [
                topChatListHeader(
                  unreadCount: unreadOrders.length,
                  totalOrders: widget.order.length,
                ),
                userSummaryCard(
                  unreadOrders: unreadOrders.length,
                  totalOrders: widget.order.length,
                ),

                // ✅ Admin banner — show karo jab admin ne message bheja ho
                if (adminDataLoaded && orderIdsWithAdminChat.isNotEmpty)
                  _adminBanner(uid: uid),

                Expanded(
                  child: widget.order.isEmpty
                      ? noOrderChatLayout()
                      : ListView(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 28),
                    children: [
                      if (unreadOrders.isNotEmpty) ...[
                        sectionTitleLayout(
                          title: "Unread messages",
                          count: unreadOrders.length,
                          isUnread: true,
                        ),
                        ...unreadOrders.map((orders) {
                          final String orderId =
                          orders.orderId.toString();
                          return whatsappOrderCard(
                            orders: orders,
                            unreadCount:
                            unreadCountByOrderId[orderId] ?? 0,
                            isUnread: true,
                          );
                        }),
                        const SizedBox(height: 4),
                      ],
                      if (readOrders.isNotEmpty) ...[
                        sectionTitleLayout(
                          title: unreadOrders.isEmpty
                              ? "All chats"
                              : "Other chats",
                          count: readOrders.length,
                          isUnread: false,
                        ),
                        ...readOrders.map((orders) {
                          return whatsappOrderCard(
                            orders: orders,
                            unreadCount: 0,
                            isUnread: false,
                          );
                        }),
                      ],
                    ],
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

    final List<String> adminOrderIds = orderIdsWithAdminChat.toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: hasUnread ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: adminBlue.withOpacity(hasUnread ? 0.45 : 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: adminBlue.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: adminBlue.withOpacity(0.14),
                  border: Border.all(color: adminBlue.withOpacity(0.35)),
                ),
                child: Icon(Icons.admin_panel_settings_rounded,
                    color: adminBlue, size: 17),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Admin Support",
                      style: TextStyle(
                        color: Color(0xFF0B164A),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasUnread
                          ? "$totalUnread unread message${totalUnread == 1 ? "" : "s"} from admin"
                          : "${adminOrderIds.length} active support chat${adminOrderIds.length == 1 ? "" : "s"}",
                      style: TextStyle(
                        color: hasUnread
                            ? adminBlue
                            : const Color(0xFF0B164A).withOpacity(0.52),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
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
                    color: adminBlue.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: adminBlue.withOpacity(0.35)),
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

          // Order tiles
          if (adminOrderIds.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...adminOrderIds.map((orderId) {
              final int unread = adminUnreadByOrderId[orderId] ?? 0;
              final bool orderHasUnread = unread > 0;

              return Padding(
                padding: const EdgeInsets.only(top: 5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminWriterChatScreen(
                          writerFirebaseUid: uid,
                          orderId: int.tryParse(orderId) ?? 0,
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
                          ? adminBlue.withOpacity(0.10)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: orderHasUnread
                            ? adminBlue.withOpacity(0.35)
                            : Colors.grey.withOpacity(0.15),
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
                              : const Color(0xFF0B164A).withOpacity(0.45),
                          size: 14,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            "#Order $orderId — Admin Chat",
                            style: TextStyle(
                              color: const Color(0xFF0B164A),
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
                              color: const Color(0xFF0B164A).withOpacity(0.40),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: orderHasUnread
                              ? adminBlue
                              : const Color(0xFF0B164A).withOpacity(0.30),
                          size: 11,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
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

  // ── Existing Widgets (unchanged) ──────────────────────────────────────────

  Widget topChatListHeader({
    required int unreadCount,
    required int totalOrders,
  }) {
    final String userName = widget.order.isNotEmpty
        ? widget.order[0].userName.toString()
        : "User";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(17),
          bottomRight: Radius.circular(17),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$userName's Orders",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  unreadCount > 0
                      ? "$unreadCount unread • $totalOrders total"
                      : "$totalOrders order chat${totalOrders == 1 ? "" : "s"}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 19),
          ),
        ],
      ),
    );
  }

  Widget userSummaryCard({
    required int unreadOrders,
    required int totalOrders,
  }) {
    final String userName = widget.order.isNotEmpty
        ? widget.order[0].userName.toString()
        : "User";

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 9, 10, 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE8FF),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset("assets/images/user.png",
                      width: 44, height: 44, fit: BoxFit.cover),
                ),
              ),
              if (unreadOrders > 0)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    height: 16,
                    width: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: whatsappGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      unreadOrders > 9 ? "9+" : "$unreadOrders",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
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
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unreadOrders > 0
                      ? "You have new user messages"
                      : "Tap any order to open chat",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.52),
                    fontSize: 10.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          compactPill(
            unreadOrders > 0 ? "$unreadOrders new" : "$totalOrders chats",
            unreadOrders > 0 ? whatsappGreen : purpleColor,
            unreadOrders > 0
                ? whatsappGreen.withOpacity(0.10)
                : const Color(0xFFEDE8FF),
          ),
        ],
      ),
    );
  }

  Widget sectionTitleLayout({
    required String title,
    required int count,
    required bool isUnread,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 7, 2, 5),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: primaryColor.withOpacity(0.62),
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isUnread
                  ? whatsappGreen.withOpacity(0.10)
                  : const Color(0xFFEDE8FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$count",
              style: TextStyle(
                color: isUnread ? whatsappGreen : purpleColor,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget whatsappOrderCard({
    required Userchatlistmodel orders,
    required int unreadCount,
    required bool isUnread,
  }) {
    final StatusUi statusUi = getStatusUi(orders.orderStatus ?? "");

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chatdetailscreen(order: orders),
          ),
        );
        if (mounted) setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.fromLTRB(9, 9, 9, 9),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF2FFF6) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? whatsappGreen.withOpacity(0.25)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isUnread ? 0.065 : 0.038),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: isUnread
                    ? whatsappGreen.withOpacity(0.13)
                    : const Color(0xFFEDE8FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnread
                    ? Icons.mark_chat_unread_rounded
                    : Icons.chat_bubble_outline_rounded,
                color: isUnread ? whatsappGreen : purpleColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Order #${orders.orderId}",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: isUnread
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isUnread)
                        unreadBadge(unreadCount)
                      else
                        Text(
                          "Open",
                          style: TextStyle(
                            color: primaryColor.withOpacity(0.38),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isUnread
                              ? "New message from user"
                              : (orders.userName ?? "Open conversation"),
                          style: TextStyle(
                            color: isUnread
                                ? primaryColor.withOpacity(0.88)
                                : primaryColor.withOpacity(0.48),
                            fontSize: 11,
                            fontWeight: isUnread
                                ? FontWeight.w900
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      statusChipLayout(
                        statusUi.bgColor,
                        statusUi.textColor,
                        statusUi.icon,
                        statusUi.text,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isUnread
                            ? whatsappGreen
                            : primaryColor.withOpacity(0.28),
                        size: 20,
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

  Widget unreadBadge(int count) {
    return Container(
      height: 19,
      constraints: const BoxConstraints(minWidth: 19),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: whatsappGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        count > 99 ? "99+" : "$count",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget compactPill(String title, Color textColor, Color pillBgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: pillBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget statusChipLayout(
      Color bgColor, Color textColor, IconData statusIcon, String statusText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration:
      BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: textColor, size: 11),
          const SizedBox(width: 3),
          Text(statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: textColor)),
        ],
      ),
    );
  }

  StatusUi getStatusUi(String status) {
    if (status == "ACCEPT") {
      return StatusUi(
          bgColor: const Color(0xFFE9F8EF),
          textColor: Colors.green.shade700,
          icon: Icons.check_circle_outline_rounded,
          text: "ACCEPTED");
    }
    if (status == "IN_PROGRESS") {
      return StatusUi(
          bgColor: const Color(0xFFEAF3FF),
          textColor: Colors.blue.shade700,
          icon: Icons.play_circle_outline_rounded,
          text: "IN PROGRESS");
    }
    if (status == "REVIEW") {
      return StatusUi(
          bgColor: const Color(0xFFFFF2D9),
          textColor: Colors.orange.shade800,
          icon: Icons.hourglass_top_rounded,
          text: "REVIEW");
    }
    if (status.contains("REQUEST")) {
      return StatusUi(
          bgColor: const Color(0xFFFFE9EC),
          textColor: Colors.red.shade600,
          icon: Icons.edit_note_rounded,
          text: status);
    }
    return StatusUi(
        bgColor: const Color(0xFFEDE8FF),
        textColor: purpleColor,
        icon: Icons.chat_bubble_outline_rounded,
        text: status.isEmpty ? "CHAT" : status);
  }

  Widget noOrderChatLayout() {
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
                  color: Color(0xFFEDE8FF), shape: BoxShape.circle),
              child: Icon(Icons.chat_bubble_outline_rounded,
                  color: purpleColor, size: 34),
            ),
            const SizedBox(height: 14),
            Text("No order chats",
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(
              "Order conversations will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: primaryColor.withOpacity(0.55),
                  fontSize: 12.5,
                  height: 1.3,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusUi {
  final Color bgColor;
  final Color textColor;
  final IconData icon;
  final String text;

  StatusUi(
      {required this.bgColor,
        required this.textColor,
        required this.icon,
        required this.text});
}