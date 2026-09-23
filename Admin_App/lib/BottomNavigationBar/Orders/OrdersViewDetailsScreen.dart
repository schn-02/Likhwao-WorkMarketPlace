import 'dart:convert';

import 'package:adminlikhwao/ApiConfig/apiConfig.dart';
import 'package:adminlikhwao/BottomNavigationBar/Disputes/submissionHistoryScreen.dart';
import 'package:adminlikhwao/ChatsScreen/AdminUserChatScreen.dart';
import 'package:adminlikhwao/ChatsScreen/UserAndWriterChatsScreen.dart';
import 'package:adminlikhwao/Model/OrdersViewDetailsModel.dart';
import 'package:adminlikhwao/Model/UserChatListModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Ordersviewdetailsscreen extends StatefulWidget {
  final int orderId;

  const Ordersviewdetailsscreen({
    super.key,
    required this.orderId,
  });

  @override
  State<Ordersviewdetailsscreen> createState() =>
      _OrdersviewdetailsscreenState();
}

class _OrdersviewdetailsscreenState
    extends State<Ordersviewdetailsscreen> {

  late Future<Ordersviewdetailsmodel> detailsFuture;

  final Color bg = const Color(0xFF07111F);
  final Color card = const Color(0xFF0E1B2E);
  final Color card2 = const Color(0xFF13243A);
  final Color primary = const Color(0xFF4FA3FF);
  final Color textColor = const Color(0xFFF3F7FF);
  final Color subText = const Color(0xFF9FB0C7);
  final Color border = const Color(0xFF22344D);
  final Color red = const Color(0xFFFF5C5C);
  final Color green = const Color(0xFF3DDC84);
  final Color orange = const Color(0xFFFFB020);

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  void loadDetails() {
    detailsFuture = fetchOrderDetails(disputeId: widget.orderId);
  }

  Future<void> refreshDetails() async {
    setState(() {
      loadDetails();
    });

    await detailsFuture;
  }

  Future<Ordersviewdetailsmodel> fetchOrderDetails({
    required int disputeId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Admin not logged in");
    }

    final token = await user.getIdToken();

    final response = await http.get(
      Uri.parse(
        "${apiConfig.baseUrl}/api/admin/orders/${widget.orderId}/details",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    Map<String, dynamic> body = {};

    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Invalid server response");
    }

    if (response.statusCode == 200 && body["status"] == "success") {
      return Ordersviewdetailsmodel.fromJson(body);
    }

    throw Exception(
      body["message"]?.toString() ?? "Failed to load order details",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1B33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          " Order Details #${widget.orderId}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<Ordersviewdetailsmodel>(
        future: detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (snapshot.hasError) {
            return errorLayout(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return errorLayout("No details found");
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: refreshDetails,
            color: primary,
            backgroundColor: card,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
              children: [
                const SizedBox(height: 12),
                quickFilesCard(data),

                const SizedBox(height: 12),
                section(
                  title: "Order Details",
                  icon: Icons.assignment_outlined,
                  children: [
                    infoTile("Order Status", data.orderStatus),
                    infoTile(
                      "Writer Assignment Status",
                      data.writerAssignmentStatus,
                    ),
                    infoTile("Type Of Work", data.typeOfWork),
                    infoTile("Language", data.selectedLanguage),
                    infoTile("Ink Color", data.selectedInkColor),
                    infoTile("Notebook", data.selectedNotebook),
                    infoTile("Pages", data.filePageCount.toString()),
                    infoTile("Deadline", formatDeadlineDateTime(data.deadline)),
                    infoTile("Urgency", data.urgency),
                    infoTile("Work To Be Done", data.workToBeDone),
                    infoTile("Writer Suggestion", data.writerSuggestionText),
                    infoTile(
                      "Order Created At",
                      formatDateTime(data.orderCreatedAt),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                section(
                  title: "User Details",
                  icon: Icons.person_outline,
                  children: [
                    infoTile("User Name", data.userName),
                    infoTile("User Number", data.userNumber),
                    infoTile("User Firebase UID", data.userFirebaseUid),
                  ],
                ),
                const SizedBox(height: 12),
                section(
                  title: "Writer Details",
                  icon: Icons.edit_outlined,
                  children: [
                    infoTile("Writer Name", data.writerName),
                    infoTile("Writer Firebase UID", data.writerFirebaseUid),
                  ],
                ),
                const SizedBox(height: 12),
                section(
                  title: "Original User File",
                  icon: Icons.picture_as_pdf_outlined,
                  children: [
                    clickableFileTile(
                      title: "File Name",
                      fileName: data.fileName,
                      onTap: () async {
                        final signedUrl = await getUserFileSignedUrlByPath(
                          orderId: data.orderId,
                        );

                        if (signedUrl == null || signedUrl.isEmpty) {
                          showSnack("Unable to generate user file URL", orange);
                          return;
                        }

                        await openUrl(signedUrl);
                      },
                    ),
                    infoTile("File Pages", data.filePageCount.toString()),
                    infoTile("File Size", formatFileSize(data.fileSize)),
                  ],
                ),
                const SizedBox(height: 12),
                section(
                  title: "Writer Submission",
                  icon: Icons.upload_file_outlined,
                  children: [
                    clickableFileTile(
                      title: "Submission File Name",
                      fileName: data.writerSubmissionFileName,
                      onTap: () async {
                        final signedUrl = await getWriterFileSignedUrlByPath(
                          orderId: data.orderId,
                        );

                        if (signedUrl == null || signedUrl.isEmpty) {
                          showSnack(
                            "Unable to generate writer file URL",
                            orange,
                          );
                          return;
                        }

                        await openUrl(signedUrl);
                      },
                    ),
                    infoTile(
                      "Submission Version",
                      data.writerSubmissionVersion,
                    ),
                    infoTile("Writer Note", data.writerSubmissionText),
                    infoTile(
                      "Submitted At",
                      formatDateTime(data.writerSubmittedAt),
                    ),
                    submissionHistoryCard(data),
                  ],
                ),
                const SizedBox(height: 12),
                section(
                  title: "Payment Details",
                  icon: Icons.payments_outlined,
                  children: [
                    infoTile("Payment Status", data.paymentStatus),
                    infoTile("Payment Method", data.paymentMethod),
                    infoTile("Payment Bank", data.paymentBank),
                    infoTile(
                      "Page Amount",
                      "₹${data.orderPageCountAmount}",
                    ),
                    infoTile("Urgency Amount", "₹${data.urgencyAmount}"),
                    infoTile(
                      "Delivery Charges",
                      "₹${data.deliveryChargesAmount}",
                    ),
                    infoTile(
                      "Notebook Charges",
                      "₹${data.noteBookChargesAmount}",
                    ),
                    infoTile("Platform Fee", "₹${data.platformFeeAmount}"),
                    infoTile("Total Amount", "₹${data.totalOrderAmount}"),
                  ],
                ),
                const SizedBox(height: 12),
                section(
                  title: "Delivery Details",
                  icon: Icons.location_on_outlined,
                  children: [
                    infoTile("Delivery/Pickup", data.deliveryPickupOption),
                    infoTile("Address", data.deliveryAddress),
                  ],
                ),
                const SizedBox(height: 20),
                actionButtons(data),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget quickFilesCard(Ordersviewdetailsmodel data) {
    final bool hasUserFile = data.fileName.trim().isNotEmpty;
    final bool hasWriterFile = data.writerSubmissionFileName.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_open_rounded, color: primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Quick Files",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "Open or download important order files quickly",
            style: TextStyle(
              color: subText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: quickFileButton(
                  title: "User File",
                  subtitle: hasUserFile ? "Original file" : "Not available",
                  icon: Icons.picture_as_pdf_outlined,
                  enabled: hasUserFile,
                  onTap: () async {
                    final signedUrl = await getUserFileSignedUrlByPath(
                      orderId: data.orderId,
                    );

                    if (signedUrl == null || signedUrl.isEmpty) {
                      showSnack("Unable to generate user file URL", orange);
                      return;
                    }

                    await openUrl(signedUrl);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: quickFileButton(
                  title: "Writer File",
                  subtitle:
                  hasWriterFile ? "Latest submission" : "Not available",
                  icon: Icons.upload_file_outlined,
                  enabled: hasWriterFile,
                  onTap: () async {
                    final signedUrl = await getWriterFileSignedUrlByPath(
                      orderId: data.orderId,
                    );

                    if (signedUrl == null || signedUrl.isEmpty) {
                      showSnack("Unable to generate writer file URL", orange);
                      return;
                    }

                    await openUrl(signedUrl);
                  },
                ),
              ),
            ],
          ),
          if (data.writerSubmissionVideoUrl.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            directFileButton(
              title: "Writer Video",
              icon: Icons.play_circle_outline,
              url: data.writerSubmissionVideoUrl,
            ),
          ],
        ],
      ),
    );
  }

  Widget section({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          maintainState: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
          iconColor: primary,
          collapsedIconColor: primary,
          textColor: textColor,
          collapsedTextColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          leading: Icon(icon, color: primary, size: 21),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget infoTile(String title, String value) {
    final clean = value.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: card2,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border.withOpacity(0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: subText,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            clean.isEmpty ? "-" : clean,
            style: TextStyle(
              color: textColor,
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget clickableFileTile({
    required String title,
    required String fileName,
    required Future<void> Function() onTap,
  }) {
    final cleanName = fileName.trim();
    final bool hasName = cleanName.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: hasName
            ? () async {
          await onTap();
        }
            : null,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: card2,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: border.withOpacity(0.75)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: subText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.link_rounded,
                    color: hasName ? primary : subText,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasName ? cleanName : "-",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasName ? primary : textColor,
                        fontSize: 13.8,
                        height: 1.35,
                        fontWeight: FontWeight.bold,
                        decoration: hasName
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationColor: primary,
                        decorationThickness: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget submissionHistoryCard(Ordersviewdetailsmodel data) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          print("View Submission History clicked");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => submissionHistoryScreen(
                orderId: data.orderId,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 2, bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.11),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: primary.withOpacity(0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.17),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Submission History",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "View all writer uploaded versions",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subText,
                        fontSize: 11.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primary.withOpacity(0.30),
                  ),
                ),
                child: Text(
                  "VIEW",
                  style: TextStyle(
                    color: primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: primary,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget quickFileButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    required Future<void> Function() onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled
            ? () async {
          await onTap();
        }
            : null,
        child: Container(
          height: 72,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: enabled ? primary.withOpacity(0.11) : card2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled ? primary.withOpacity(0.35) : border,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: enabled ? primary.withOpacity(0.16) : border,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: enabled ? primary : subText,
                  size: 21,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: enabled ? textColor : subText,
                        fontSize: 12.8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: enabled ? primary : subText,
                        fontSize: 10.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.download_rounded,
                color: enabled ? primary : subText,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget directFileButton({
    required String title,
    required IconData icon,
    required String url,
  }) {
    final bool hasUrl = url.trim().isNotEmpty;

    return SizedBox(
      height: 43,
      child: ElevatedButton.icon(
        onPressed: hasUrl
            ? () {
          openUrl(url);
        }
            : null,
        icon: Icon(icon, size: 18),
        label: FittedBox(
          child: Text(
            hasUrl ? title : "$title N/A",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: card2,
          disabledForegroundColor: subText,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  Widget actionButtons(
      Ordersviewdetailsmodel data,
      ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.075),
            blurRadius: 14,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final Userchatlistmodel chatOrder = Userchatlistmodel(
                    orderId: data.orderId,
                    userName: data.userName,
                    userFirebaseUid:data.userFirebaseUid,
                    orderStatus: data.orderStatus
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chatdetailscreen(
                      order: chatOrder,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text(
                "Conversation Between user and writer",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 9),



          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: OutlinedButton.icon(
                    onPressed: () {


                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminUserChatScreen(
                            orderId: data.orderId,
                            receiverFirebaseUid: data.userFirebaseUid,
                            receiverName: data.userName,
                            chatTarget: "toUser",
                          ),
                        ),
                      );

                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text(
                      "Chat with User",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: red,
                      side: BorderSide(color: red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminUserChatScreen(
                            orderId: data.orderId,
                            receiverFirebaseUid: data.writerFirebaseUid,
                            receiverName: data.writerName,
                            chatTarget: "toWriter",
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text(
                      "Chat with Writer",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }


  String getValueFromData(
      Map<String, dynamic> data,
      List<String> keys,
      String defaultValue,
      ) {
    for (String key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        String value = data[key].toString().trim();

        if (value.isNotEmpty && value != "null") {
          return value;
        }
      }
    }

    return defaultValue;
  }

  Widget circleIcon(IconData icon, Color color) {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget errorLayout(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: red.withOpacity(0.45)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: red, size: 38),
              const SizedBox(height: 12),
              Text(
                "Unable to load details",
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subText,
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: refreshDetails,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openUrl(String url) async {
    try {
      final cleanUrl = url.trim();

      if (cleanUrl.isEmpty) {
        showSnack("File URL not available", orange);
        return;
      }

      final uri = Uri.tryParse(cleanUrl);

      if (uri == null || !uri.hasScheme) {
        showSnack("Invalid URL", red);
        return;
      }

      final opened = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );

      if (!opened) {
        showSnack("Unable to open file", red);
      }
    } catch (e) {
      showSnack("Unable to open file: $e", red);
    }
  }

  void showSnack(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  String formatFileSize(int bytes) {
    if (bytes <= 0) return "-";

    final kb = bytes / 1024;
    final mb = kb / 1024;

    if (mb >= 1) {
      return "${mb.toStringAsFixed(2)} MB";
    }

    return "${kb.toStringAsFixed(2)} KB";
  }

  String formatDateTime(String value) {
    final clean = value.trim();

    if (clean.isEmpty || clean == "-") {
      return "-";
    }

    final parsed = parseFlexibleDateTime(clean);

    if (parsed == null) {
      return clean;
    }

    return formatReadableDateTime(parsed);
  }

  String formatDeadlineDateTime(String value) {
    final clean = value.trim();

    if (clean.isEmpty || clean == "-") {
      return "-";
    }

    final parsed = parseFlexibleDateTime(
      clean,
      forceNoonIfDateOnly: true,
    );

    if (parsed == null) {
      return clean;
    }

    return formatReadableDateTime(parsed);
  }

  DateTime? parseFlexibleDateTime(
      String value, {
        bool forceNoonIfDateOnly = false,
      }) {
    final clean = value.trim();

    if (clean.isEmpty) return null;

    try {
      final isoDateOnlyRegex = RegExp(r'^\d{4}-\d{1,2}-\d{1,2}$');

      if (isoDateOnlyRegex.hasMatch(clean)) {
        final parts = clean.split("-");
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);

        return DateTime(
          year,
          month,
          day,
          forceNoonIfDateOnly ? 12 : 0,
          0,
        );
      }

      return DateTime.parse(clean).toLocal();
    } catch (_) {}

    final ymdRegex = RegExp(
      r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?\s*(AM|PM|am|pm)?)?$',
    );

    final ymdMatch = ymdRegex.firstMatch(clean);

    if (ymdMatch != null) {
      return buildDateFromMatch(
        year: ymdMatch.group(1),
        month: ymdMatch.group(2),
        day: ymdMatch.group(3),
        hour: ymdMatch.group(4),
        minute: ymdMatch.group(5),
        second: ymdMatch.group(6),
        amPm: ymdMatch.group(7),
        forceNoonIfDateOnly: forceNoonIfDateOnly,
      );
    }

    final dmyRegex = RegExp(
      r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?\s*(AM|PM|am|pm)?)?$',
    );

    final dmyMatch = dmyRegex.firstMatch(clean);

    if (dmyMatch != null) {
      return buildDateFromMatch(
        year: dmyMatch.group(3),
        month: dmyMatch.group(2),
        day: dmyMatch.group(1),
        hour: dmyMatch.group(4),
        minute: dmyMatch.group(5),
        second: dmyMatch.group(6),
        amPm: dmyMatch.group(7),
        forceNoonIfDateOnly: forceNoonIfDateOnly,
      );
    }

    final firebaseRegex = RegExp(
      r'^([A-Za-z]{3,9})\s+(\d{1,2}),\s*(\d{4})(?:\s+at\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\s*(AM|PM|am|pm)?)?',
    );

    final firebaseMatch = firebaseRegex.firstMatch(clean);

    if (firebaseMatch != null) {
      final monthNumber = monthNameToNumber(firebaseMatch.group(1) ?? "");

      if (monthNumber == null) return null;

      return buildDateFromMatch(
        year: firebaseMatch.group(3),
        month: monthNumber.toString(),
        day: firebaseMatch.group(2),
        hour: firebaseMatch.group(4),
        minute: firebaseMatch.group(5),
        second: firebaseMatch.group(6),
        amPm: firebaseMatch.group(7),
        forceNoonIfDateOnly: forceNoonIfDateOnly,
      );
    }

    return null;
  }

  DateTime? buildDateFromMatch({
    required String? year,
    required String? month,
    required String? day,
    required String? hour,
    required String? minute,
    required String? second,
    required String? amPm,
    required bool forceNoonIfDateOnly,
  }) {
    try {
      final y = int.parse(year ?? "0");
      final m = int.parse(month ?? "0");
      final d = int.parse(day ?? "0");

      final bool hasTime = hour != null && minute != null;

      int h = hasTime ? int.parse(hour) : 0;
      final min = hasTime ? int.parse(minute) : 0;
      final sec = second == null ? 0 : int.parse(second);

      if (!hasTime && forceNoonIfDateOnly) {
        h = 12;
      }

      if (hasTime && amPm != null) {
        final upperAmPm = amPm.toUpperCase();

        if (upperAmPm == "PM" && h < 12) {
          h += 12;
        }

        if (upperAmPm == "AM" && h == 12) {
          h = 0;
        }
      }

      return DateTime(y, m, d, h, min, sec);
    } catch (_) {
      return null;
    }
  }

  String formatReadableDateTime(DateTime dateTime) {
    final months = [
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

    final day = twoDigit(dateTime.day);
    final month = months[dateTime.month - 1];
    final year = dateTime.year;

    int hour = dateTime.hour % 12;
    if (hour == 0) hour = 12;

    final minute = twoDigit(dateTime.minute);
    final amPm = dateTime.hour >= 12 ? "PM" : "AM";

    return "$day $month $year, ${twoDigit(hour)}:$minute $amPm";
  }

  String twoDigit(int value) {
    return value.toString().padLeft(2, "0");
  }

  int? monthNameToNumber(String monthName) {
    final clean = monthName.trim().toLowerCase();

    final months = {
      "jan": 1,
      "january": 1,
      "feb": 2,
      "february": 2,
      "mar": 3,
      "march": 3,
      "apr": 4,
      "april": 4,
      "may": 5,
      "jun": 6,
      "june": 6,
      "jul": 7,
      "july": 7,
      "aug": 8,
      "august": 8,
      "sep": 9,
      "sept": 9,
      "september": 9,
      "oct": 10,
      "october": 10,
      "nov": 11,
      "november": 11,
      "dec": 12,
      "december": 12,
    };

    return months[clean];
  }

  Future<String?> getUserFileSignedUrlByPath({
    required int orderId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("ADMIN NOT LOGGED IN");
        return null;
      }

      final token = await user.getIdToken(true);

      if (token == null || token.isEmpty) {
        print("TOKEN NOT FOUND");
        return null;
      }

      final url = "${apiConfig.baseUrl}/api/admin/files/$orderId/user-file-url";

      print("ADMIN USER FILE SIGNED URL API: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("ADMIN USER FILE SIGNED URL STATUS: ${response.statusCode}");
      print("ADMIN USER FILE SIGNED URL BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["url"] != null) {
          return data["url"].toString();
        }
      }

      return null;
    } catch (e) {
      print("ADMIN USER FILE SIGNED URL ERROR: $e");
      return null;
    }
  }

  Future<String?> getWriterFileSignedUrlByPath({
    required int orderId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("ADMIN NOT LOGGED IN");
        return null;
      }

      final token = await user.getIdToken(true);

      if (token == null || token.isEmpty) {
        print("TOKEN NOT FOUND");
        return null;
      }

      final url =
          "${apiConfig.baseUrl}/api/admin/files/$orderId/writer-file-url";

      print("ADMIN WRITER FILE SIGNED URL API: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("ADMIN WRITER FILE SIGNED URL STATUS: ${response.statusCode}");
      print("ADMIN WRITER FILE SIGNED URL BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["url"] != null) {
          return data["url"].toString();
        }
      }

      return null;
    } catch (e) {
      print("ADMIN WRITER FILE SIGNED URL ERROR: $e");
      return null;
    }
  }
}