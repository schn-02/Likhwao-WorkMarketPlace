import 'dart:convert';

import 'package:adminlikhwao/ApiConfig/apiConfig.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminUserChatScreen extends StatefulWidget {
  final String receiverFirebaseUid; // user ya writer ka UID
  final String receiverName;        // user ya writer ka naam
  final int orderId;
  final String chatTarget;          // "toUser" ya "toWriter"

  const AdminUserChatScreen({
    super.key,
    required this.receiverFirebaseUid,
    required this.receiverName,
    required this.orderId,
    required this.chatTarget,
  });

  @override
  State<AdminUserChatScreen> createState() => _AdminUserChatScreenState();
}

class _AdminUserChatScreenState extends State<AdminUserChatScreen> {
  final TextEditingController chatEditorTextController =
  TextEditingController();
  final FocusNode chatFocusNode = FocusNode();

  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);
  final Color greenColor = const Color(0xFF22C55E);

  final List<Map<String, dynamic>> pendingMessages = [];

  // ── Dynamic getters based on chatTarget ──────────────────────────────────

  bool get _isToWriter => widget.chatTarget == "toWriter";

  String get _collectionName =>
      _isToWriter ? "admin_writer_chats" : "admin_user_chats";

  String get _docId =>
      _isToWriter
          ? "ADMIN_WRITER_${widget.orderId}"
          : "ADMIN_USER_${widget.orderId}";

  String get _receiverPrefix => _isToWriter ? "WRITER" : "USER";

  String get _chatLabel =>
      _isToWriter ? "Admin → Writer Chat" : "Admin → User Chat";

  String get _chatSubLabel =>
      _isToWriter
          ? "Direct writer support for Order #${widget.orderId}"
          : "Direct user support for Order #${widget.orderId}";

  String get _receiverLabel => _isToWriter ? "Writer" : "User";

  Color get _receiverLabelColor =>
      _isToWriter ? greenColor : Colors.blue.shade700;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    chatEditorTextController.dispose();
    chatFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            _buildOrderInfoStrip(),
            Expanded(child: _buildMessageLayout()),
            _buildChatEditor(),
          ],
        ),
      ),
    );
  }

  // ─── Top Header ───────────────────────────────────────────────────────────

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE8FF),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                "assets/images/user.png",
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Text(
                  "Order #${widget.orderId}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Order Info Strip ─────────────────────────────────────────────────────

  Widget _buildOrderInfoStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE8FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isToWriter
                  ? Icons.edit_note_rounded
                  : Icons.support_agent_rounded,
              color: purpleColor,
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chatLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _chatSubLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.52),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings_rounded,
                    color: purpleColor, size: 15),
                const SizedBox(width: 4),
                Text(
                  "ADMIN",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: purpleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Message Layout ───────────────────────────────────────────────────────

  Widget _buildMessageLayout() {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Center(
        child: Text(
          "Not logged in",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _getMessagesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            pendingMessages.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: purpleColor),
          );
        }

        final List<Map<String, dynamic>> firestoreMessages = [];

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            firestoreMessages.add({
              "id": doc.id,
              "clientMessageId": data["clientMessageId"]?.toString() ?? "",
              "message": data["message"]?.toString() ?? "",
              "senderId": data["senderId"]?.toString() ?? "",
              "receiverId": data["receiverId"]?.toString() ?? "",
              "senderFirebaseUid":
              data["senderFirebaseUid"]?.toString() ?? "",
              "receiverFirebaseUid":
              data["receiverFirebaseUid"]?.toString() ?? "",
              "timestamp": data["timestamp"],
              "isPending": false,
              "isRead": data["isRead"] == true,
            });
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _markMessagesAsRead(snapshot.data!.docs);
          });
        }

        final Set<String> realClientIds = firestoreMessages
            .map((m) => m["clientMessageId"]?.toString() ?? "")
            .where((id) => id.isNotEmpty)
            .toSet();

        final List<Map<String, dynamic>> visiblePending = pendingMessages
            .where((p) => !realClientIds
            .contains(p["clientMessageId"]?.toString() ?? ""))
            .toList();

        if (visiblePending.length != pendingMessages.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              pendingMessages.removeWhere((p) => realClientIds
                  .contains(p["clientMessageId"]?.toString() ?? ""));
            });
          });
        }

        final List<Map<String, dynamic>> allMessages = [
          ...visiblePending,
          ...firestoreMessages,
        ];

        if (allMessages.isEmpty) return _buildNoMessageLayout();

        return ListView.builder(
          reverse: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(2, 8, 2, 8),
          itemCount: allMessages.length,
          itemBuilder: (context, index) {
            final data = allMessages[index];
            final DateTime dateTime = _getDateTime(data["timestamp"]);
            final String formattedTime = _formatTime(dateTime);
            final String senderId = data["senderId"]?.toString() ?? "";
            final bool isAdmin = senderId.startsWith("ADMIN_");
            final bool isPending = data["isPending"] == true;
            final bool isRead = data["isRead"] == true;
            final String message = data["message"]?.toString() ?? "";

            bool showDateDivider = false;
            if (index == allMessages.length - 1) {
              showDateDivider = true;
            } else {
              final DateTime nextDate =
              _getDateTime(allMessages[index + 1]["timestamp"]);
              if (!_isSameDate(dateTime, nextDate)) showDateDivider = true;
            }

            final Widget bubble = isAdmin
                ? _buildAdminBubble(message, formattedTime,
                isPending: isPending, isRead: isRead)
                : _buildReceiverBubble(message, formattedTime);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showDateDivider)
                  _buildDateDivider(_getDateHeader(dateTime)),
                bubble,
              ],
            );
          },
        );
      },
    );
  }

  // ─── Message Bubbles ──────────────────────────────────────────────────────

  /// Admin ka message — RIGHT side, purple
  Widget _buildAdminBubble(
      String message,
      String formattedTime, {
        bool isPending = false,
        bool isRead = false,
      }) {
    return Align(
      alignment: Alignment.centerRight,
      child: Opacity(
        opacity: isPending ? 0.70 : 1,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 285),
          margin: const EdgeInsets.fromLTRB(64, 5, 12, 5),
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 8),
          decoration: BoxDecoration(
            color: purpleColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(5),
            ),
            boxShadow: [
              BoxShadow(
                color: purpleColor.withOpacity(0.16),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Admin",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.30,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isPending
                        ? Icons.access_time_rounded
                        : Icons.done_all_rounded,
                    color: isRead
                        ? const Color(0xff7CFF9B)
                        : Colors.white.withOpacity(0.72),
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// User ya Writer ka message — LEFT side, white
  Widget _buildReceiverBubble(String message, String formattedTime) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 285),
        margin: const EdgeInsets.fromLTRB(12, 5, 64, 5),
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: Colors.grey.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic label — "User" ya "Writer"
            Text(
              _receiverLabel,
              style: TextStyle(
                color: _receiverLabelColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              message,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.30,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formattedTime,
              style: TextStyle(
                color: primaryColor.withOpacity(0.42),
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Supporting Widgets ───────────────────────────────────────────────────

  Widget _buildDateDivider(String title) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.07)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: primaryColor.withOpacity(0.68),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildNoMessageLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 82,
              width: 82,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE8FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: purpleColor,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "No messages yet",
              style: TextStyle(
                color: primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              "Start the conversation with the $_receiverLabel.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor.withOpacity(0.55),
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Chat Editor ──────────────────────────────────────────────────────────

  Widget _buildChatEditor() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.075),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () => debugPrint("Attachment clicked"),
            child: Container(
              height: 46,
              width: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F7FF),
                shape: BoxShape.circle,
              ),
              child:
              Icon(Icons.attach_file_rounded, color: purpleColor, size: 23),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints:
              const BoxConstraints(minHeight: 46, maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.withOpacity(0.14)),
              ),
              child: TextField(
                focusNode: chatFocusNode,
                controller: chatEditorTextController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Message to $_receiverLabel...",
                  hintStyle: TextStyle(
                    color: primaryColor.withOpacity(0.38),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: _sendMessage,
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: purpleColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: purpleColor.withOpacity(0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Send Message ─────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final String message = chatEditorTextController.text.trim();
    if (message.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final String? adminUid = user?.uid;
    final String receiverUid = widget.receiverFirebaseUid;

    if (user == null || adminUid == null || receiverUid.trim().isEmpty) {
      debugPrint("UID IS NULL");
      return;
    }

    final String clientMessageId =
        "msg_${DateTime.now().microsecondsSinceEpoch}_$adminUid";
    final DateTime now = DateTime.now();

    chatEditorTextController.clear();

    setState(() {
      pendingMessages.insert(0, {
        "id": clientMessageId,
        "clientMessageId": clientMessageId,
        "message": message,
        "senderId": "ADMIN_$adminUid",
        "receiverId": "${_receiverPrefix}_$receiverUid", // dynamic
        "senderFirebaseUid": adminUid,
        "receiverFirebaseUid": receiverUid,
        "timestamp": now,
        "isPending": true,
        "isRead": false,
      });
    });

    try {
      final token = await user.getIdToken(true);

      final url = Uri.parse(
          "${apiConfig.baseUrl}/api/writer_side/chats/sendMessage");

      final Map<String, dynamic> requestBody = {
        "orderId": widget.orderId,
        "receiverFirebaseUid": receiverUid,
        "message": message,
        "clientMessageId": clientMessageId,
        "role": "admin",
        "chatTo": widget.chatTarget, // "toUser" ya "toWriter" — dynamic
      };

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Admin→$_receiverLabel message sent successfully");
        return;
      }

      debugPrint("SEND ERROR: ${response.statusCode} — ${response.body}");

      if (!mounted) return;

      setState(() {
        pendingMessages
            .removeWhere((m) => m["clientMessageId"] == clientMessageId);
      });

      chatEditorTextController.text = message;
      chatFocusNode.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.body.contains("contact")
                ? "Contact details share karna allowed nahi hai."
                : "Message send failed. Try again.",
          ),
        ),
      );
    } catch (e) {
      debugPrint("SEND EXCEPTION: $e");

      if (!mounted) return;

      setState(() {
        pendingMessages
            .removeWhere((m) => m["clientMessageId"] == clientMessageId);
      });

      chatEditorTextController.text = message;
      chatFocusNode.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Try again.")),
      );
    }
  }

  // ─── Firestore Stream ─────────────────────────────────────────────────────

  Stream<QuerySnapshot> _getMessagesStream() {
    final String? adminUid = FirebaseAuth.instance.currentUser?.uid;

    if (adminUid == null || widget.receiverFirebaseUid.trim().isEmpty) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection(_collectionName) // dynamic collection
        .doc(_docId)                 // dynamic doc ID
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // ─── Mark As Read

  Future<void> _markMessagesAsRead(List<QueryDocumentSnapshot> docs) async {
    final String? adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) return;

    final String currentId = "ADMIN_$adminUid";
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    int count = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String receiverId = data["receiverId"]?.toString() ?? "";
      final bool isRead = data["isRead"] == true;

      if (receiverId == currentId && !isRead) {
        batch.update(doc.reference, {
          "isRead": true,
          "readAt": FieldValue.serverTimestamp(),
        });
        count++;
      }
    }

    if (count == 0) return;

    try {
      await batch.commit();
      debugPrint("Admin marked $count messages as read ($_receiverLabel chat)");
    } catch (e) {
      debugPrint("READ UPDATE ERROR: $e");
    }
  }

  // ─── Helpers

  DateTime _getDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(date.year, date.month, date.day);

    if (msgDay == today) return "Today";
    if (msgDay == yesterday) return "Yesterday";

    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    if (date.year == now.year) return "${date.day} ${months[date.month - 1]}";
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formatTime(DateTime dt) {
    final int hour = dt.hour;
    final int minute = dt.minute;
    final String amPm = hour >= 12 ? "PM" : "AM";
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;
    return "$displayHour:${minute.toString().padLeft(2, '0')} $amPm";
  }
}