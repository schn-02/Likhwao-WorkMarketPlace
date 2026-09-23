import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:likhwao/Model/WriterWorkModel.dart';
import 'package:likhwao/PdfPreviewScreenFromDB.dart';

import '../../ApiConfig/apiConfig.dart';
import '../../Toast/ToastHelper.dart';

class Worksummary extends StatefulWidget {
  final Writerworkmodel work;

  const Worksummary({
    super.key,
    required this.work,
  });

  @override
  State<Worksummary> createState() => _WorksummaryState();
}

class _WorksummaryState extends State<Worksummary> {
  bool isOpeningWriterFile = false;
  bool isOpeningUserFile = false;
  bool isChangingStatus = false;

  String? localStatus;

  final Color bgColor = const Color(0xFF020B2D);
  final Color cardColor = const Color(0xFF07143D);
  final Color innerCardColor = const Color(0xFF101B4D);
  final Color orangeColor = const Color(0xffFF6A00);
  final Color greenColor = const Color(0xff23C552);
  final Color purpleColor = const Color(0xFFB58CFF);

  int get orderId => widget.work.UserOrderId ?? 0;
  int get writerWorkId => widget.work.writerWorkId ?? 0;

  String get currentStatus {
    final status = localStatus ??
        widget.work.writerAssignmentStatus?.toString() ??
        "REVIEW";

    return status.toUpperCase();
  }

  bool isCurrentStatusChangesRequested() {
    final status = currentStatus;

    return status == "REQUEST_CHANGES" || status == "CHANGES_REQUESTED";
  }


  bool isCurrentStatusCompleted() {
    final status = currentStatus;

    return status.contains("COMPLETED") || status.contains("ACCEPTED");
  }

  bool isCurrentStatusDisputed() {
    final status = currentStatus;

    return status == "DISPUTED" ||
        status == "OPEN_DISPUTE" ||
        status.contains("DISPUTE");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "WORK SUMMARY",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 2,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
          child: Column(
            children: [
              orderPicAndTypeOfWork(),
              const SizedBox(height: 14),
              writerWorkSummary(),
              const SizedBox(height: 14),
              requestChangesHistory(),
              const SizedBox(height: 14),
              userSummary(),
              SizedBox(
                height: isCurrentStatusCompleted()
                    ? 20
                    : isCurrentStatusChangesRequested()
                    ? 86
                    : isCurrentStatusDisputed()
                    ? 118
                    : 170,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomActionBar(),
    );
  }

  Widget bottomActionBar() {
    if (isCurrentStatusCompleted()) {
      return const SizedBox.shrink();
    }

    final bool isChangesRequested = isCurrentStatusChangesRequested();
    final bool isDisputed = isCurrentStatusDisputed();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            versionChip(),
            const SizedBox(height: 12),
            if (isDisputed)
              disputeRaisedInfoCard()
            else if (isChangesRequested)
              waitingForWriterNextUpload()
            else
              actionButtonsLayout(),
          ],
        ),
      ),
    );
  }

  Widget disputeRaisedInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xffFF3B30).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xffFF3B30).withOpacity(0.38),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xffFF3B30).withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Color(0xffFF6B61),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dispute Raised",
                  style: TextStyle(
                    color: Color(0xffFF6B61),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your issue has been sent to admin. Admin will review your order and contact you soon.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget waitingForWriterNextUpload() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: orangeColor.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: orangeColor.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: orangeColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              color: orangeColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Waiting for writer's next upload.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.88),
                fontSize: 13.5,
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

  Widget actionButtonsLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: isChangingStatus
                    ? null
                    : () {
                  showRequestChangesDialog();
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: orangeColor.withOpacity(0.85),
                    ),
                  ),
                  child: Center(
                    child: isChangingStatus
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Request Changes",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: isChangingStatus
                    ? null
                    : () {
                  showAcceptDialog();
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff23C552),
                        Color(0xff07963A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: greenColor.withOpacity(0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isChangingStatus
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Accept Work",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isChangingStatus
              ? null
              : () {
            showRaiseDisputeDialog();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xffFF3B30).withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xffFF3B30).withOpacity(0.65),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.report_problem_rounded,
                  color: Color(0xffFF6B61),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Having a serious issue?",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "Raise Dispute",
                        style: TextStyle(
                          color: Color(0xffFF6B61),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  void showRaiseDisputeDialog() {
    final TextEditingController disputeMessageController =
    TextEditingController();

    String selectedReason = "Work is incomplete";

    final List<String> disputeReasons = [
      "Work is incomplete",
      "Wrong work submitted",
      "Poor quality work",
      "Writer not following instructions",
      "Payment/order issue",
      "Other",
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xff1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                "Raise Dispute",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Select reason",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xff2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedReason,
                          dropdownColor: const Color(0xff2A2A2A),
                          isExpanded: true,
                          iconEnabledColor: Colors.white70,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          items: disputeReasons.map((reason) {
                            return DropdownMenuItem<String>(
                              value: reason,
                              child: Text(reason),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setDialogState(() {
                              selectedReason = value;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Explain your issue",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: disputeMessageController,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText:
                        "Example: Writer ne page 5 to 8 complete nahi kiye hain.",
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xff2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xffFF6B61),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFF3B30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final message = disputeMessageController.text.trim();

                    if (message.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please explain your issue"),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    raiseDispute(
                      reason: selectedReason,
                      message: message,
                    );
                  },
                  child: const Text(
                    "Submit Dispute",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> raiseDispute({
    required String reason,
    required String message,
  }) async {
    if (orderId == 0) {
      ToastHelper.show("Order id missing", context);
      return;
    }

    try {
      setState(() {
        isChangingStatus = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final String? token = await user.getIdToken(true);

      if (token == null || token.isEmpty) {
        throw Exception("Firebase token not found");
      }

      final Uri url = Uri.parse(
        "${apiConfig.baseUrl}/api/user/orders/$orderId/raise-dispute",
      );

      final Map<String, dynamic> body = {
        "reason": reason,
        "message": message,
      };

      final http.Response response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("RAISE DISPUTE STATUS: ${response.statusCode}");
      print("RAISE DISPUTE BODY: ${response.body}");

      Map<String, dynamic> responseBody = {};

      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseBody = decoded;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        setState(() {
          localStatus = responseBody["orderStatus"]?.toString() ?? "DISPUTED";
        });

        ToastHelper.show(
          responseBody["message"]?.toString() ??
              "Dispute raised successfully",
          context,
        );
      } else {
        throw Exception(
          responseBody["message"]?.toString() ??
              "Failed to raise dispute",
        );
      }
    } catch (e) {
      if (!mounted) return;

      ToastHelper.show(
        e.toString().replaceFirst("Exception: ", ""),
        context,
      );
    } finally {
      if (mounted) {
        setState(() {
          isChangingStatus = false;
        });
      }
    }
  }

  Widget versionChip() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("orders")
          .doc(orderId.toString())
          .snapshots(),
      builder: (context, snapshot) {
        String version = "1";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          version = data['latestSubmissionVersion']?.toString() ?? "1";
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: greenColor.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: greenColor.withOpacity(0.35),
            ),
          ),
          child: Text(
            "Version $version • Latest Upload",
            style: const TextStyle(
              color: Color(0xff7CFF9B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      },
    );
  }

  Widget orderPicAndTypeOfWork() {
    final status = currentStatus;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF07184A),
            Color(0xFF120B3F),
            Color(0xFF21104F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF8D5CFF).withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 74,
            width: 74,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8D5CFF),
                  Color(0xFF4B1AB8),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.assignment_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.work.typeOfWork?.toString() ?? "Handwritten Work",
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 6),
                Text(
                  "Order #${widget.work.UserOrderId}",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: purpleColor,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                statusBadge(status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget statusBadge(String status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.45),
        ),
      ),
      child: Text(
        _cleanStatus(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget writerWorkSummary() {
    final String status = currentStatus;
    final Color statusColor = _getStatusColor(status);

    final String lastUpdate = widget.work.orderCompletedAtReview != null
        ? DateFormat('dd MMM yyyy').format(widget.work.orderCompletedAtReview!)
        : "Not available";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Latest Writer Uploaded Work",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: statusColor.withOpacity(0.45),
                  ),
                ),
                child: Text(
                  _cleanStatus(status),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.update_rounded,
                color: Colors.white.withOpacity(0.55),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Last Update: $lastUpdate",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.62),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          filenameAndFileView(),
        ],
      ),
    );
  }

  Widget filenameAndFileView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        children: [
          _darkRow("File name", widget.work.fileName),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: isOpeningWriterFile
                ? null
                : () async {
              await openWriterLatestFile();
            },
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffFF7A00),
                    Color(0xffFF4D00),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: orangeColor.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Center(
                child: isOpeningWriterFile
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Opening...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.remove_red_eye_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "View Writer File",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          writerMessageBox(),
        ],
      ),
    );
  }

  Widget writerMessageBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8D5CFF).withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Writer's Message",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.work.writerSuggestionText?.toString().isNotEmpty == true
                ? widget.work.writerSuggestionText.toString()
                : "No message from writer.",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.white.withOpacity(0.62),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget requestChangesHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Request Changes History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("orders")
                .doc(orderId.toString())
                .collection("writerSubmission")
                .orderBy("version", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: orangeColor,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  "Unable to load history",
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontWeight: FontWeight.w800,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return noChangesHistory();
              }

              final changeDocs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final text = data['changeRequestText']?.toString() ?? "";
                return text.trim().isNotEmpty && text != "null";
              }).toList();

              if (changeDocs.isEmpty) {
                return noChangesHistory();
              }

              return Column(
                children: changeDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return changeHistoryCard(data);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget noChangesHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Text(
        "No request changes yet.",
        style: TextStyle(
          color: Colors.white.withOpacity(0.58),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget changeHistoryCard(Map<String, dynamic> data) {
    final version = data['version']?.toString() ?? "-";
    final text = data['changeRequestText']?.toString() ?? "";
    final requestedAt = formatDateTime(data['changeRequestedAt']);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF101B4D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: orangeColor.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: orangeColor.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: orangeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Version V$version",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                if (requestedAt.isNotEmpty)
                  Text(
                    requestedAt,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 7),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget userSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Column(
        children: [
          expansionTileOrderSummary(),
          const SizedBox(height: 12),
          paymentSummary(),
        ],
      ),
    );
  }

  Widget expansionTileOrderSummary() {
    String typeOfWork = widget.work.typeOfWork?.toString() ?? "-";
    String pageCount = widget.work.userFilePageCount?.toString() ?? "-";
    String inkColour = widget.work.selectedInkColor?.toString() ?? "-";
    String userFileName = widget.work.userFileName?.toString() ?? " Your File ";
    DateTime? deadlineDate = widget.work.selectedDate;

    String deadlineText = deadlineDate != null
        ? DateFormat('dd MMM yyyy').format(deadlineDate)
        : "Not selected";

    String selectedNotebook = widget.work.selectedNotebook?.toString() ?? "-";
    String deliveryUrgency =
        widget.work.selectedDeadLineUrgency?.toString() ?? "-";

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: innerCardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.07),
          ),
        ),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: orangeColor,
          title: const Text(
            "Order Summary",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            "Type of Work: $typeOfWork",
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
          childrenPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          children: [
            Row(
              children: [
                Text(
                  "View your file",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.58),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: isOpeningUserFile
                        ? null
                        : () async {
                      await openUserFile();
                    },
                    child: isOpeningUserFile
                        ? const Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                        : Text(
                       userFileName,
                      style: TextStyle(
                        color: purpleColor,
                        fontWeight: FontWeight.w900,
                      ),
                      softWrap: true,
                      maxLines: 2,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _darkRow("Urgency", deliveryUrgency),
            _darkRow("Page Count", pageCount),
            _darkRow("Deadline", deadlineText),
            _darkRow("Ink Colour", inkColour),
            _darkRow("Selected Notebook", selectedNotebook),
          ],
        ),
      ),
    );
  }

  Widget paymentSummary() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: innerCardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.07),
          ),
        ),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: orangeColor,
          title: const Text(
            "Payment Summary",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            "Total Amount: ₹${widget.work.totalOrderAmount ?? 0}",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.55),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          childrenPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          children: [
            paymentDetails(
              "Page Charges",
              "₹ ${((widget.work.userFilePageCount ?? 0) * 10)}",
            ),
            if (widget.work.selectedDeadLineUrgency != "Normal(2-3 days)")
              paymentDetails(
                "Urgency Charges",
                "₹ ${widget.work.urgencyAmount ?? 0}",
              ),
            if ((widget.work.noteBookChargesAmount ?? 0) > 0)
              paymentDetails(
                "Company Notebook Charges",
                "₹ ${widget.work.noteBookChargesAmount}",
              ),
            paymentDetails(
              "Platform Fee",
              "₹ ${widget.work.platformFeeAmount ?? 0}",
            ),
            Divider(
              color: Colors.white.withOpacity(0.12),
            ),
            paymentDetails(
              "Total Payable Amount",
              "₹ ${widget.work.totalOrderAmount ?? 0}",
              isBold: true,
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: greenColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: greenColor.withOpacity(0.30),
                ),
              ),
              child: const Text(
                "Your data is 100% safe",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff7CFF9B),
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _darkRow(String title, String? value, {bool isBold = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value ?? "-",
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentDetails(String title, String value, {bool isBold = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isBold ? const Color(0xffFFB000) : Colors.white,
                fontSize: isBold ? 14.5 : 13.5,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.24),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  void showRequestChangesDialog() {
    TextEditingController changeController = TextEditingController();

    if (writerWorkId == 0) {
      ToastHelper.show("Writer work id missing", context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Request Changes",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Please describe what you want the writer to change.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: changeController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Write changes here...",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.38),
                ),
                filled: true,
                fillColor: innerCardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: orangeColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              String changeText = changeController.text.trim();

              if (changeText.isEmpty) {
                ToastHelper.show("Please enter change description", context);
                return;
              }

              Navigator.pop(context);

              Writerworkmodel w = Writerworkmodel(
                writerAssignmentStatus: "REQUEST_CHANGES",
                writerFirebaseUid: widget.work.writerFirebaseUid,
                UserOrderId: widget.work.UserOrderId,
                writerWorkId: widget.work.writerWorkId,
                UserRequestChangeDescription: changeText,
              );

              await changeStatus(w);
            },
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAcceptDialog() {
    if (writerWorkId == 0) {
      ToastHelper.show("Writer work id missing", context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Confirm",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          "Are you sure you want to accept this work?\n\nOnce accepted, payment will be released and you can't request changes.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.68),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              Writerworkmodel w = Writerworkmodel(
                writerAssignmentStatus: "COMPLETED",
                writerFirebaseUid: widget.work.writerFirebaseUid,
                UserOrderId: widget.work.UserOrderId,
                writerWorkId: widget.work.writerWorkId,
              );

              await changeStatus(w);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Accept",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> openWriterLatestFile() async {
    if (orderId == 0) {
      ToastHelper.show("Order id missing", context);
      return;
    }

    setState(() {
      isOpeningWriterFile = true;
    });

    try {
      final signedUrl = await getWriterFileSignedUrl(orderId);
      final fileName = widget.work.fileName?.toString() ?? "writer_file.pdf";

      if (!mounted) return;

      if (signedUrl == null || signedUrl.isEmpty) {
        ToastHelper.show("File url is null", context);
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Pdfpreviewscreenfromdb(
            fileUrl: signedUrl,
            fileName: fileName,
          ),
        ),
      );
    } catch (e) {
      print("Open writer file error: $e");
      ToastHelper.show("Unable to open file", context);
    } finally {
      if (mounted) {
        setState(() {
          isOpeningWriterFile = false;
        });
      }
    }
  }

  Future<void> openUserFile() async {
    if (orderId == 0) {
      ToastHelper.show("Order id missing", context);
      return;
    }

    setState(() {
      isOpeningUserFile = true;
    });

    try {
      final signedUrl = await getUserFileSignedUrl(orderId);
      final fileName = widget.work.userFileName?.toString() ?? "user_file.pdf";

      if (!mounted) return;

      if (signedUrl == null || signedUrl.isEmpty) {
        ToastHelper.show("File url is null", context);
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Pdfpreviewscreenfromdb(
            fileUrl: signedUrl,
            fileName: fileName,
          ),
        ),
      );
    } catch (e) {
      print("Open user file error: $e");
      ToastHelper.show("Unable to open file", context);
    } finally {
      if (mounted) {
        setState(() {
          isOpeningUserFile = false;
        });
      }
    }
  }

  Future<void> changeStatus(Writerworkmodel w) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ToastHelper.show("User not logged in", context);
      return;
    }

    if (w.writerWorkId == null || w.writerWorkId == 0) {
      ToastHelper.show("Writer work id missing", context);
      return;
    }

    setState(() {
      isChangingStatus = true;
    });

    try {
      final token = await user.getIdToken(true);

      final url = Uri.parse(
        "${apiConfig.baseUrl}/api/user_side/orders/writerAssignmentStatus",
      );

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(w.toJson()),
      );

      print("CHANGE STATUS CODE: ${response.statusCode}");
      print("CHANGE STATUS BODY: ${response.body}");

      if (response.statusCode == 200) {
        ToastHelper.show("Status updated successfully", context);

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        ToastHelper.show("Status update failed", context);
      }
    } catch (e) {
      print("Change status error: $e");
      ToastHelper.show("Something went wrong", context);
    } finally {
      if (mounted) {
        setState(() {
          isChangingStatus = false;
        });
      }
    }
  }

  Future<String?> getWriterFileSignedUrl(int orderId) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken(true);

    final response = await http.get(
      Uri.parse("${apiConfig.baseUrl}/api/user_side/$orderId/writer-file-url"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("WRITER FILE URL STATUS: ${response.statusCode}");
    print("WRITER FILE URL BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["url"];
    }

    return null;
  }

  Future<String?> getUserFileSignedUrl(int orderId) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken(true);

    final response = await http.get(
      Uri.parse(
        "${apiConfig.baseUrl}/api/writer_side/orders/$orderId/user-file-url",
      ),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("USER FILE URL STATUS: ${response.statusCode}");
    print("USER FILE URL BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    }

    return null;
  }

  Color _getStatusColor(String status) {
    final upperStatus = status.toUpperCase();

    if (upperStatus.contains("DISPUTE")) {
      return const Color(0xffFF6B61);
    }

    if (upperStatus.contains("COMPLETED") ||
        upperStatus.contains("ACCEPTED")) {
      return greenColor;
    }

    if (upperStatus.contains("CHANGE")) {
      return orangeColor;
    }

    if (upperStatus.contains("REVIEW")) {
      return const Color(0xff2F80ED);
    }

    if (upperStatus.contains("PROGRESS")) {
      return const Color(0xffFFB000);
    }

    return purpleColor;
  }

  String _cleanStatus(String status) {
    final upperStatus = status.toUpperCase();

    if (upperStatus == "DISPUTED" || upperStatus.contains("DISPUTE")) {
      return "ADMIN REVIEWING DISPUTE";
    }

    if (upperStatus == "ON_REVIEW" || upperStatus == "REVIEW") {
      return "UNDER REVIEW";
    }

    if (upperStatus == "CHANGES_REQUESTED" ||
        upperStatus == "REQUEST_CHANGES") {
      return "CHANGES REQUESTED";
    }

    return status.replaceAll("_", " ").replaceAll("-", " ").toUpperCase();
  }
  String formatDateTime(dynamic value) {
    try {
      if (value == null) {
        return "";
      }

      if (value is Timestamp) {
        return DateFormat('dd MMM yyyy, hh:mm a').format(value.toDate());
      }

      DateTime dateTime = DateTime.parse(value.toString());
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return value?.toString() ?? "";
    }
  }
}