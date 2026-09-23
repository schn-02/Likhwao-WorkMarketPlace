import 'dart:convert';

import 'package:adminlikhwao/ApiConfig/apiConfig.dart';
import 'package:adminlikhwao/Model/UserChatListModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Chatdetailscreen extends StatefulWidget {
  final  Userchatlistmodel order;

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

  final FocusNode chatFocusNode = FocusNode();

  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);

  final List<Map<String, dynamic>> pendingMessages = [];

  @override
  void dispose() {
    chatEditorTextController.dispose();
    chatFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color statusBgColor;
    Color statusTextColor;
    IconData statusIcon;
    String statusText = widget.order.orderStatus ?? "";

    if (widget.order.orderStatus == "ACCEPT") {
      statusBgColor = const Color(0xFFE9F8EF);
      statusTextColor = Colors.green.shade700;
      statusIcon = Icons.check_circle_outline_rounded;
      statusText = "ACCEPTED";
    } else if (widget.order.orderStatus == "IN_PROGRESS") {
      statusBgColor = const Color(0xFFEAF3FF);
      statusTextColor = Colors.blue.shade700;
      statusIcon = Icons.play_circle_outline_rounded;
      statusText = "IN_PROGRESS";
    } else if (widget.order.orderStatus == "REVIEW") {
      statusBgColor = const Color(0xFFFFF2D9);
      statusTextColor = Colors.orange.shade800;
      statusIcon = Icons.hourglass_top_rounded;
      statusText = "REVIEW";
    } else if ((widget.order.orderStatus ?? "").contains("REQUEST")) {
      statusBgColor = const Color(0xFFFFE9EC);
      statusTextColor = Colors.red.shade600;
      statusIcon = Icons.edit_note_rounded;
      statusText = widget.order.orderStatus ?? "REQUEST_CHANGES";
    } else {
      statusBgColor = const Color(0xFFEDE8FF);
      statusTextColor = purpleColor;
      statusIcon = Icons.chat_bubble_outline_rounded;
    }

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            chatTopHeader(
              statusBgColor,
              statusTextColor,
              statusIcon,
              statusText,
            ),
            orderInfoStrip(
              statusBgColor,
              statusTextColor,
              statusIcon,
              statusText,
            ),
            Expanded(
              child: messageLayout(),
            ),
            chatEditor(),
          ],
        ),
      ),
    );
  }

  Widget chatTopHeader(
      Color statusBgColor,
      Color statusTextColor,
      IconData statusIcon,
      String statusText,
      ) {
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
            onTap: () {
              Navigator.pop(context);
            },
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
                  widget.order.userName ?? "",
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
                  "Order #${widget.order.orderId}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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

  Widget orderInfoStrip(
      Color statusBgColor,
      Color statusTextColor,
      IconData statusIcon,
      String statusText,
      ) {
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
              Icons.assignment_rounded,
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
                  "Order-specific chat",
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
                  "Messages are linked with Order #${widget.order.orderId}",
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
          statusChipLayout(
            statusBgColor,
            statusTextColor,
            statusIcon,
            statusText,
          ),
        ],
      ),
    );
  }

  Widget statusChipLayout(
      Color statusBgColor,
      Color statusTextColor,
      IconData statusIcon,
      String statusText,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusTextColor,
            size: 15,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: statusTextColor,
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
          constraints: const BoxConstraints(
            maxWidth: 285,
          ),
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

  Widget receiverMessageLayout(String message, String formattedTime) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 285,
        ),
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
          border: Border.all(
            color: Colors.grey.withOpacity(0.12),
          ),
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
            // User label
            Text(
              "User",
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            // Message
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

  Widget dateDividerLayout(String title) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withOpacity(0.07),
          ),
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

  Widget messageLayout() {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Center(
        child: Text(
          "Anonymous User",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final String currentChatId = "WRITER_$uid";

    return StreamBuilder<QuerySnapshot>(
      stream: getMessageDataFromFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            pendingMessages.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: purpleColor,
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
              "senderFirebaseUid":
              data["senderFirebaseUid"]?.toString() ?? "",
              "receiverFirebaseUid":
              data["receiverFirebaseUid"]?.toString() ?? "",
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

        final List<Map<String, dynamic>> visiblePendingMessages = [];

        for (final pending in pendingMessages) {
          final String pendingClientId =
              pending["clientMessageId"]?.toString() ?? "";

          if (!realClientIds.contains(pendingClientId)) {
            visiblePendingMessages.add(pending);
          }
        }

        if (visiblePendingMessages.length != pendingMessages.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            pendingMessages.removeWhere((pending) {
              final String pendingClientId =
                  pending["clientMessageId"]?.toString() ?? "";
              return realClientIds.contains(pendingClientId);
            });
          });
        }

        final List<Map<String, dynamic>> finalMessages = [
          ...visiblePendingMessages,
          ...firestoreMessages,
        ];

        if (finalMessages.isEmpty) {
          return noMessageLayout();
        }

        return ListView.builder(
          reverse: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(2, 8, 2, 8),
          itemCount: finalMessages.length,
          itemBuilder: (context, index) {
            final data = finalMessages[index];

            final DateTime dateTime = getDateTimeFromAny(data["timestamp"]);
            final String formattedTime = formatChatTime(dateTime);

            final bool isMe = data["senderId"] == currentChatId;

            final String senderId = data["senderId"]?.toString() ??"";

            final bool isAdmin = senderId.startsWith("ADMIN_");
            final bool isWriter = senderId.startsWith("WRITER_");
            final bool isUser = senderId.startsWith("USER_");

            final String message = data["message"]?.toString() ?? "";
            final bool isPending = data["isPending"] == true;
            final bool isRead = data["isRead"] == true;

            bool showDateDivider = false;

            if (index == finalMessages.length - 1) {
              showDateDivider = true;
            } else {
              final DateTime nextMessageDate =
              getDateTimeFromAny(finalMessages[index + 1]["timestamp"]);

              if (!isSameDate(dateTime, nextMessageDate)) {
                showDateDivider = true;
              }
            }

            // final Widget messageBubble = isMe
            //     ? senderMessageLayout(
            //   message,
            //   formattedTime,
            //   isPending: isPending,
            //   isRead: isRead,
            // )
            //     : receiverMessageLayout(
            //   message,
            //   formattedTime,
            // );
            //
            final Widget messageBubble =isAdmin?senderMessageLayout(message, formattedTime ,
                isPending: isPending , isRead: isRead
            ) :isWriter ?writerMessageLayout(message, formattedTime)
                :receiverMessageLayout(message, formattedTime);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showDateDivider)
                  dateDividerLayout(
                    getDateHeaderText(dateTime),
                  ),
                messageBubble,
              ],
            );
          },
        );
      },
    );
  }

  Widget writerMessageLayout(String message, String formattedTime) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 285),
        margin: const EdgeInsets.fromLTRB(12, 5, 64, 5),
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9), // Light green background
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: Colors.green.withOpacity(0.18)),
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
            // Writer label
            Text(
              "Writer",
              style: TextStyle(
                color: Colors.green.shade700,
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

  Widget noMessageLayout() {
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
              "Start the conversation for this order.",
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

  Widget chatEditor() {
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
            onTap: () {
              debugPrint("Attachment clicked");
            },
            child: Container(
              height: 46,
              width: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F7FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.attach_file_rounded,
                color: purpleColor,
                size: 23,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 46,
                maxHeight: 120,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.14),
                ),
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
                  hintText: "Reply to user...",
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
            onTap: sendMessage,
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
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
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
    final String? currentAdminFirebaseUid = user?.uid;
    final String? userFirebaseUid = widget.order.userFirebaseUid;

    if (user == null ||
        currentAdminFirebaseUid == null ||
        userFirebaseUid == null ||
        userFirebaseUid.trim().isEmpty) {
      debugPrint("ID IS NULL");
      return;
    }

    final int orderId = int.tryParse(widget.order.orderId.toString()) ?? 0;

    if (orderId == 0) {
      debugPrint("ORDER ID INVALID");
      return;
    }

    final String clientMessageId =
        "msg_${DateTime.now().microsecondsSinceEpoch}_$currentAdminFirebaseUid";

    final DateTime now = DateTime.now();

    chatEditorTextController.clear();

    setState(() {
      pendingMessages.insert(0, {
        "id": clientMessageId,
        "clientMessageId": clientMessageId,
        "message": message,
        "senderId": "ADMIN_$currentAdminFirebaseUid",
        "receiverId": "USER_$userFirebaseUid",
        "senderFirebaseUid": currentAdminFirebaseUid,
        "receiverFirebaseUid": userFirebaseUid,
        "timestamp": now,
        "isPending": true,
        "isRead": false,
      });
    });

    try {
      final token = await user.getIdToken(true);

      final url = Uri.parse(
        "${apiConfig.baseUrl}/api/writer_side/chats/sendMessage",
      );

      final Map<String, dynamic> requestBody = {
        "orderId": orderId,
        "receiverFirebaseUid": userFirebaseUid,
        "message": message,
        "clientMessageId": clientMessageId,
        "role":"admin",
        "chatTo":"toUser"
      };

      debugPrint("ADMIN CHAT SEND URL: $url");
      debugPrint("ADMIN CHAT ORDER ID: $orderId");
      debugPrint("ADMIN CHAT RECEIVER USER UID: $userFirebaseUid");
      debugPrint("ADMIN CHAT CLIENT MESSAGE ID: $clientMessageId");
      debugPrint("ADMIN CHAT REQUEST BODY: ${jsonEncode(requestBody)}");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Writer message verified and sent successfully");
        return;
      }

      debugPrint("WRITER MESSAGE SEND ERROR: ${response.statusCode}");
      debugPrint("WRITER MESSAGE SEND BODY: ${response.body}");

      if (!mounted) return;

      setState(() {
        pendingMessages.removeWhere(
              (item) => item["clientMessageId"] == clientMessageId,
        );
      });

      chatEditorTextController.text = message;
      chatFocusNode.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.body.contains("contact")
                ? "Contact details share karna allowed nahi hai."
                : "Message send failed",
          ),
        ),
      );
    } catch (e) {
      debugPrint("WRITER MESSAGE SEND EXCEPTION: $e");

      if (!mounted) return;

      setState(() {
        pendingMessages.removeWhere(
              (item) => item["clientMessageId"] == clientMessageId,
        );
      });

      chatEditorTextController.text = message;
      chatFocusNode.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
  }

  Stream<QuerySnapshot> getMessageDataFromFirebase() {
    final String? currentWriterFirebaseUid =
        FirebaseAuth.instance.currentUser?.uid;
    final String? userFirebaseUid = widget.order.userFirebaseUid;

    if (currentWriterFirebaseUid == null ||
        userFirebaseUid == null ||
        userFirebaseUid.trim().isEmpty) {
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
    final String? currentWriterFirebaseUid =
        FirebaseAuth.instance.currentUser?.uid;

    if (currentWriterFirebaseUid == null) {
      return;
    }

    final String currentChatId = "WRITER_$currentWriterFirebaseUid";

    final WriteBatch batch = FirebaseFirestore.instance.batch();
    int updateCount = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final String receiverId = data["receiverId"]?.toString() ?? "";
      final bool isRead = data["isRead"] == true;

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
      debugPrint("Writer marked $updateCount messages as read");
    } catch (e) {
      debugPrint("WRITER READ UPDATE ERROR: $e");
    }
  }

  DateTime getDateTimeFromAny(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String getDateHeaderText(DateTime messageDate) {
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

  String formatChatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;

    String amPm = hour >= 12 ? "PM" : "AM";
    int displayHour = hour % 12;

    if (displayHour == 0) {
      displayHour = 12;
    }

    String minuteText = minute.toString().padLeft(2, "0");

    return "$displayHour:$minuteText $amPm";
  }
}