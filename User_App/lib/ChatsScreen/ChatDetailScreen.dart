import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:likhwao/Model/WriterChatListModel.dart';

import '../ApiConfig/apiConfig.dart';

class Chatdetailscreen extends StatefulWidget {
  final Writerchatlistmodel order;

  const Chatdetailscreen({
    super.key,
    required this.order,
  });

  @override
  State<Chatdetailscreen> createState() => _ChatdetailscreenState();
}

class _ChatdetailscreenState extends State<Chatdetailscreen> {
  final TextEditingController chatEditorTextController =
  TextEditingController();

  final Color bgColor = const Color(0xFF020B2D);
  final Color cardColor = const Color(0xFF07143D);
  final Color innerCardColor = const Color(0xFF101B4D);
  final Color orangeColor = const Color(0xffFF6A00);
  final Color purpleColor = const Color(0xFF8D5CFF);
  final Color softPurpleColor = const Color(0xFFB58CFF);
  final Color greenColor = const Color(0xff23C552);

  final List<Map<String, dynamic>> pendingMessages = [];

  @override
  void dispose() {
    chatEditorTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(widget.order.orderStatus ?? "");

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 50,
        backgroundColor: bgColor,
        leadingWidth: 44,
        leading: Padding(
          padding: const EdgeInsets.only(left: 9, top: 7, bottom: 7),
          child: InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: innerCardColor,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ),
        titleSpacing: 4,
        title: Row(
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8D5CFF),
                    Color(0xFF4B1AB8),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Image.asset(
                  "assets/images/user.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order.writerName?.toString().trim().isNotEmpty ==
                        true
                        ? widget.order.writerName.toString()
                        : "Writer",
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Order #${widget.order.orderId}",
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.white.withOpacity(0.58),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Container(
              constraints: const BoxConstraints(maxWidth: 78),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusColor.withOpacity(0.38),
                ),
              ),
              child: Text(
                _cleanStatus(widget.order.orderStatus ?? ""),
                style: TextStyle(
                  fontSize: 8.3,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 7),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _orderInfoStrip(),
            Expanded(
              child: messageLayout(),
            ),
            chatEditor(),
          ],
        ),
      ),
    );
  }

  Widget _orderInfoStrip() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Color(0xff7CFF9B),
              size: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order-based secure chat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.7,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  "Discuss requirements and work updates.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 9.8,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget senderMessageLayout(
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          margin: const EdgeInsets.only(
            left: 55,
            right: 10,
            top: 3.5,
            bottom: 3.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xffFF7A00),
                Color(0xffFF4D00),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
              bottomLeft: Radius.circular(13),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: orangeColor.withOpacity(0.14),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.22,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.70),
                      fontWeight: FontWeight.w700,
                      fontSize: 8.5,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    isPending
                        ? Icons.access_time_rounded
                        : Icons.done_all_rounded,
                    color: isRead
                        ? const Color(0xff7CFF9B)
                        : Colors.white.withOpacity(0.70),
                    size: 11.5,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget receiverMessageLayout(String message, String formattedTime) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.only(
          left: 10,
          right: 55,
          top: 3.5,
          bottom: 3.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(13),
            topRight: Radius.circular(13),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(13),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.07),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formattedTime,
              style: TextStyle(
                color: Colors.white.withOpacity(0.48),
                fontWeight: FontWeight.w700,
                fontSize: 8.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget messageLayout() {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Center(
        child: Text(
          "Anonymous User",
          style: TextStyle(
            color: Colors.white.withOpacity(0.70),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: getMessageDataFromFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            pendingMessages.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: orangeColor,
              strokeWidth: 2.3,
            ),
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
              "timestamp": data["timestamp"],
              "isPending": false,
              "isRead": data["isRead"] == true,
              "readAt": data["readAt"],
            });
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            markReceivedMessagesAsRead(snapshot.data!.docs);
          });
        }

        final Set<String> realClientIds = firestoreMessages
            .map((item) => item["clientMessageId"]?.toString() ?? "")
            .where((id) => id.isNotEmpty)
            .toSet();

        pendingMessages.removeWhere((pending) {
          final String pendingClientId =
              pending["clientMessageId"]?.toString() ?? "";
          return realClientIds.contains(pendingClientId);
        });

        final List<Map<String, dynamic>> finalMessages = [
          ...pendingMessages,
          ...firestoreMessages,
        ];

        if (finalMessages.isEmpty) {
          return _emptyMessageLayout();
        }

        return ListView.builder(
          reverse: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(top: 5, bottom: 6),
          itemCount: finalMessages.length,
          itemBuilder: (context, index) {
            final data = finalMessages[index];

            final DateTime dateTime = _getDateTimeFromAny(data["timestamp"]);

            final String formattedTime =
                "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

            final String currentChatId = "USER_$uid";
            final bool isMe = data["senderId"] == currentChatId;
            final String message = data["message"]?.toString() ?? "";
            final bool isPending = data["isPending"] == true;
            final bool isRead = data["isRead"] == true;

            bool showDateDivider = false;

            if (index == finalMessages.length - 1) {
              showDateDivider = true;
            } else {
              final DateTime nextMessageDate =
              _getDateTimeFromAny(finalMessages[index + 1]["timestamp"]);

              if (!_isSameDate(dateTime, nextMessageDate)) {
                showDateDivider = true;
              }
            }

            final Widget messageBubble = isMe
                ? senderMessageLayout(
              message,
              formattedTime,
              isPending: isPending,
              isRead: isRead,
            )
                : receiverMessageLayout(
              message,
              formattedTime,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showDateDivider)
                  dateDividerLayout(
                    _getDateHeaderText(dateTime),
                  ),
                messageBubble,
              ],
            );
          },
        );
      },
    );
  }
  Widget _emptyMessageLayout() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.46,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: purpleColor.withOpacity(0.28),
                    ),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFFB58CFF),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 11),
                const Text(
                  "Start conversation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Send your first message to discuss requirements.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget chatEditor() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 7),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 39,
                maxHeight: 84,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: TextField(
                controller: chatEditorTextController,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.8,
                  height: 1.22,
                ),
                minLines: 1,
                maxLines: 3,
                cursorColor: orangeColor,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: "Ask your query...",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.38),
                    fontSize: 11.8,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: sendMessage,
            child: Container(
              height: 39,
              width: 39,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffFF7A00),
                    Color(0xffFF4D00),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: orangeColor.withOpacity(0.16),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendMessage() async {
    final String message = chatEditorTextController.text.trim();

    if (message.isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final String? currentUserId = user?.uid;
    final String? anotherUserId = widget.order.writerFirebaseUid;

    if (user == null || currentUserId == null || anotherUserId == null) {
      debugPrint("ID IS NULL");
      return;
    }

    final int orderId = int.tryParse(widget.order.orderId.toString()) ?? 0;

    if (orderId == 0) {
      debugPrint("ORDER ID INVALID");
      return;
    }

    final String clientMessageId =
        "msg_${DateTime.now().microsecondsSinceEpoch}_$currentUserId";

    final DateTime now = DateTime.now();

    chatEditorTextController.clear();

    setState(() {
      pendingMessages.insert(0, {
        "id": clientMessageId,
        "clientMessageId": clientMessageId,
        "message": message,
        "senderId": "USER_$currentUserId",
        "receiverId": "WRITER_$anotherUserId",
        "senderFirebaseUid": currentUserId,
        "receiverFirebaseUid": anotherUserId,
        "timestamp": now,
        "isPending": true,
        "isRead": false,
      });
    });

    try {
      final token = await user.getIdToken(true);

      final url = Uri.parse(
        "${apiConfig.baseUrl}/api/user_side/chats/sendMessage",
      );

      final Map<String, dynamic> requestBody = {
        "orderId": orderId,
        "receiverFirebaseUid": anotherUserId,
        "message": message,
        "clientMessageId": clientMessageId,
        "role":"USER",
        "chatTo":"toWriter"
      };

      debugPrint("CHAT SEND URL: $url");
      debugPrint("CHAT ORDER ID: $orderId");
      debugPrint("CHAT RECEIVER UID: $anotherUserId");
      debugPrint("CHAT CLIENT MESSAGE ID: $clientMessageId");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Message verified and sent successfully");
        return;
      }

      debugPrint("MESSAGE SEND ERROR: ${response.statusCode}");
      debugPrint("MESSAGE SEND BODY: ${response.body}");

      if (!mounted) return;

      setState(() {
        pendingMessages.removeWhere(
              (item) => item["clientMessageId"] == clientMessageId,
        );
      });

      chatEditorTextController.text = message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.body.contains("contact")
                ? "You cannot share your personal  details"
                : "Message send failed",
          ),
        ),
      );
    } catch (e) {
      debugPrint("MESSAGE SEND EXCEPTION: $e");

      if (!mounted) return;

      setState(() {
        pendingMessages.removeWhere(
              (item) => item["clientMessageId"] == clientMessageId,
        );
      });

      chatEditorTextController.text = message;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
  }

  Stream<QuerySnapshot> getMessageDataFromFirebase() {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final String? anotherUserId = widget.order.writerFirebaseUid;

    if (currentUserId == null || anotherUserId == null) {
      debugPrint("ID IS NULL");
      return const Stream.empty();
    }

    final String chatId = widget.order.orderId.toString();

    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Future<void> markReceivedMessagesAsRead(
      List<QueryDocumentSnapshot> docs,
      ) async {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return;
    }

    final WriteBatch batch = FirebaseFirestore.instance.batch();
    int updateCount = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final String receiverId = data["receiverId"]?.toString() ?? "";
      final bool isRead = data["isRead"] == true;

      final String currentChatId = "USER_$currentUserId";

      if (receiverId == currentChatId && !isRead) {
        batch.update(doc.reference, {
          "isRead": true,
          "readAt": FieldValue.serverTimestamp(),
        });

        updateCount++;
      }
    }

    if (updateCount == 0) {
      return;
    }

    try {
      await batch.commit();
      debugPrint("Marked $updateCount messages as read");
    } catch (e) {
      debugPrint("READ UPDATE ERROR: $e");
    }
  }

  Color _getStatusColor(String status) {
    final String upperStatus = status.toUpperCase();

    if (upperStatus.contains("COMPLETED") ||
        upperStatus.contains("ACCEPTED")) {
      return greenColor;
    }

    if (upperStatus.contains("ACCEPT")) {
      return greenColor;
    }

    if (upperStatus.contains("PROGRESS")) {
      return const Color(0xffFFB000);
    }

    if (upperStatus.contains("REVIEW")) {
      return const Color(0xff2F80ED);
    }

    if (upperStatus.contains("FINDING")) {
      return Colors.white;
    }

    if (upperStatus.contains("CHANGE")) {
      return orangeColor;
    }

    return softPurpleColor;
  }

  String _cleanStatus(String status) {
    return status.replaceAll("_", " ").replaceAll("-", " ").toUpperCase();
  }


  DateTime _getDateTimeFromAny(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getDateHeaderText(DateTime messageDate) {
    final DateTime now = DateTime.now();

    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime msgDay = DateTime(
      messageDate.year,
      messageDate.month,
      messageDate.day,
    );

    if (msgDay == today) {
      return "Today";
    }

    if (msgDay == yesterday) {
      return "Yesterday";
    }

    const List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    if (messageDate.year == now.year) {
      return "${messageDate.day} ${months[messageDate.month - 1]}";
    }

    return "${messageDate.day} ${months[messageDate.month - 1]} ${messageDate.year}";
  }

  Widget dateDividerLayout(String title) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: innerCardColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}