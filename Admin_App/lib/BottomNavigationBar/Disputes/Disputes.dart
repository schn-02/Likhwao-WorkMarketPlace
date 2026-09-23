import 'dart:async';

import 'package:adminlikhwao/BottomNavigationBar/Disputes/AdminDisputeOrderDetailsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Disputes extends StatefulWidget {
  const Disputes({super.key});

  @override
  State<Disputes> createState() => _DisputesState();
}

class _DisputesState extends State<Disputes> {
  int selectedTab = 0;

  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  late final Stream<QuerySnapshot<Map<String, dynamic>>> disputesStream;
  Timer? searchDebounce;

  final Color bg = const Color(0xFF07111F);
  final Color card = const Color(0xFF0E1B2E);
  final Color card2 = const Color(0xFF13243A);
  final Color primary = const Color(0xFF4FA3FF);
  final Color textColor = const Color(0xFFF3F7FF);
  final Color subText = const Color(0xFF9FB0C7);
  final Color border = const Color(0xFF22344D);

  final List<String> tabs = const [
    "All",
    "Open",
    "Urgent",
    "Resolved",
  ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    disputesStream = FirebaseFirestore.instance
        .collection("disputes")
        .orderBy("createdAtTimestamp", descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: disputesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return Column(
                children: [
                  _header(),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Column(
                children: [
                  _header(),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Unable to load disputes",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final List<DisputeModel> disputes =
                snapshot.data?.docs.map((doc) {
                  return DisputeModel.fromFirestore(doc);
                }).toList() ??
                    [];

            final List<DisputeModel> filteredDisputes =
            _getFilteredDisputes(disputes);

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _header(),
                const SizedBox(height: 14),
                _summaryCards(disputes),
                const SizedBox(height: 16),
                _tabs(),
                const SizedBox(height: 12),
                _searchBox(),
                const SizedBox(height: 12),
                if (filteredDisputes.isEmpty)
                  _emptyState()
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: filteredDisputes
                          .map<Widget>(
                            (DisputeModel dispute) => _disputeCard(dispute),
                      )
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  List<DisputeModel> _getFilteredDisputes(List<DisputeModel> disputes) {
    List<DisputeModel> filtered = disputes;

    if (selectedTab == 1) {
      filtered = filtered.where((d) => d.status == "Open").toList();
    } else if (selectedTab == 2) {
      filtered = filtered.where((d) => d.priority == "Urgent").toList();
    } else if (selectedTab == 3) {
      filtered = filtered.where((d) => d.status == "Resolved").toList();
    }

    if (searchText.trim().isNotEmpty) {
      final query = searchText.trim().toLowerCase();

      filtered = filtered.where((d) {
        return d.id.toLowerCase().contains(query) ||
            d.orderId.toLowerCase().contains(query) ||
            d.userName.toLowerCase().contains(query) ||
            d.writerName.toLowerCase().contains(query) ||
            d.issueTitle.toLowerCase().contains(query) ||
            d.description.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      color: const Color(0xFF0B1B33),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Disputes",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(Icons.notifications_none, color: textColor),
        ],
      ),
    );
  }

  Widget _summaryCards(List<DisputeModel> disputes) {
    final int open = disputes.where((d) => d.status == "Open").length;
    final int urgent = disputes.where((d) => d.priority == "Urgent").length;
    final int resolved = disputes.where((d) => d.status == "Resolved").length;

    return SizedBox(
      height: 95,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          _summaryCard(
            "Open",
            open.toString(),
            Icons.warning_amber_rounded,
            Colors.orange,
          ),
          const SizedBox(width: 10),
          _summaryCard(
            "Urgent",
            urgent.toString(),
            Icons.priority_high,
            Colors.redAccent,
          ),
          const SizedBox(width: 10),
          _summaryCard(
            "Resolved",
            resolved.toString(),
            Icons.check_circle_outline,
            Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      width: 135,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: subText, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final bool active = selectedTab == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: (){
                setState(() {
                  selectedTab = index;
                });


              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? primary.withOpacity(0.18) : card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: active ? primary : border),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: active ? primary : subText,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: subText, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  searchDebounce?.cancel();

                  searchDebounce = Timer(
                    const Duration(milliseconds: 300),
                        () {
                      if (!mounted) return;

                      setState(() {
                        searchText = value;
                      });
                    },
                  );
                },

                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search dispute, order, user...",
                  hintStyle: TextStyle(color: subText, fontSize: 13),
                ),
              ),
            ),
            if (searchText.isNotEmpty)
              InkWell(
                onTap: () {
                  searchDebounce?.cancel();
                  searchController.clear();
                  FocusScope.of(context).unfocus();

                  setState(() {
                    searchText = "";
                  });
                },
                child: Icon(Icons.close, color: subText, size: 20),
              )
            else
              Icon(Icons.sort, color: subText, size: 21),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.report_gmailerrorred_outlined,
              color: subText,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              "No disputes found",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "New user disputes will appear here automatically.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subText,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _disputeCard(DisputeModel dispute) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dispute.readByAdmin ? border : Colors.redAccent,
          width: dispute.readByAdmin ? 1 : 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _iconBox(dispute.color),
              _smallInfo("Dispute ID", dispute.id),
              _smallInfo("Order ID", dispute.orderId),
              _statusChip(dispute.status, dispute.color),
              _statusChip(dispute.priority, dispute.color),
              if (!dispute.readByAdmin)
                _statusChip("New", Colors.redAccent),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            dispute.issueTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dispute.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subText,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          _detailsBox(dispute),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _actionButton(
                title: "View Details",
                icon: Icons.visibility_outlined,
                filled: false,
                onTap: () {
                  final int disputeId = dispute.rawDisputeId != 0
                      ? dispute.rawDisputeId
                      : int.tryParse(dispute.documentId) ?? 0;

                  if (disputeId == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Invalid dispute id"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  _markAsRead(dispute);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminDisputeOrderDetailsScreen(
                        disputeId: disputeId,
                      ),
                    ),
                  );
                },
              ),
              if (dispute.status != "Resolved")
                _actionButton(
                  title: "Resolve",
                  icon: Icons.check_circle_outline,
                  filled: true,
                  onTap: () {
                    _showResolveDialog(dispute);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailsBox(DisputeModel dispute) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _infoLine(Icons.person_outline, "User: ${dispute.userName}"),
          const SizedBox(height: 8),
          _infoLine(Icons.edit_outlined, "Writer: ${dispute.writerName}"),
          const SizedBox(height: 8),
          _infoLine(
            Icons.description_outlined,
            "File: ${dispute.fileName}",
          ),
          const SizedBox(height: 8),
          _infoLine(Icons.access_time, dispute.time, color: Colors.orange),
        ],
      ),
    );
  }

  Widget _smallInfo(String title, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 125),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: subText, fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(Color color) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.report_problem_outlined, color: color, size: 25),
    );
  }

  Widget _statusChip(String status, Color color) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 155),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? subText, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color ?? subText,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String title,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 130, maxWidth: 170),
      child: SizedBox(
        height: 43,
        child: filled
            ? ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: FittedBox(child: Text(title)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )
            : OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18, color: primary),
          label: FittedBox(
            child: Text(
              title,
              style: TextStyle(color: primary),
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  void _showDisputeDetails(DisputeModel dispute) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 45,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Dispute Details",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _detailTile("Dispute ID", dispute.id),
                _detailTile("Order ID", dispute.orderId),
                _detailTile("Status", dispute.status),
                _detailTile("Priority", dispute.priority),
                _detailTile("Reason", dispute.issueTitle),
                _detailTile("Message", dispute.description),
                _detailTile("User Name", dispute.userName),
                _detailTile("User Number", dispute.userNumber),
                _detailTile("Writer", dispute.writerName),
                _detailTile("Writer UID", dispute.writerFirebaseUid),
                _detailTile("File Name", dispute.fileName),
                _detailTile("Page Count", dispute.filePageCount.toString()),
                _detailTile("Total Amount", "₹${dispute.totalOrderAmount}"),
                _detailTile(
                  "Writer Submission Version",
                  dispute.writerSubmissionVersion,
                ),
                _detailTile("Created At", dispute.time),
                const SizedBox(height: 18),
                if (dispute.status != "Resolved")
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showResolveDialog(dispute);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        "Resolve Dispute",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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

  Widget _detailTile(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: subText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value.isEmpty ? "-" : value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(DisputeModel dispute) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            "Resolve Dispute",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: noteController,
            maxLines: 4,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: "Add admin resolution note...",
              hintStyle: TextStyle(color: subText),
              filled: true,
              fillColor: card2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                noteController.dispose();
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: subText),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final note = noteController.text.trim();
                noteController.dispose();
                Navigator.pop(context);

                await _resolveDispute(dispute, note);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Resolve"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markAsRead(DisputeModel dispute) async {
    if (dispute.readByAdmin) return;

    try {
      await FirebaseFirestore.instance
          .collection("disputes")
          .doc(dispute.documentId)
          .set(
        {
          "readByAdmin": true,
          "updatedAtTimestamp": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint("Mark read error: $e");
    }
  }

  Future<void> _resolveDispute(DisputeModel dispute, String note) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final WriteBatch batch = firestore.batch();

      final disputeRef =
      firestore.collection("disputes").doc(dispute.documentId);

      final orderRef = firestore
          .collection("orders")
          .doc(dispute.rawOrderId.toString());

      batch.set(
        disputeRef,
        {
          "disputeStatus": "RESOLVED",
          "statusLabel": "Dispute Resolved",
          "readByAdmin": true,
          "adminResolutionNote": note,
          "resolvedAtTimestamp": FieldValue.serverTimestamp(),
          "updatedAtTimestamp": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      batch.set(
        orderRef,
        {
          "disputeStatus": "RESOLVED",
          "statusLabel": "Dispute Resolved by Admin",
          "hasDispute": false,
          "updatedAtTimestamp": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Dispute resolved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Resolve dispute error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to resolve dispute: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class DisputeModel {
  final String documentId;
  final int rawDisputeId;
  final int rawOrderId;

  final String id;
  final String orderId;
  final String userName;
  final String userNumber;
  final String writerName;
  final String writerFirebaseUid;
  final String issueTitle;
  final String description;
  final String status;
  final String priority;
  final String time;
  final Color color;

  final String fileName;
  final int filePageCount;
  final int totalOrderAmount;
  final String writerSubmissionVersion;
  final bool readByAdmin;

  const DisputeModel({
    required this.documentId,
    required this.rawDisputeId,
    required this.rawOrderId,
    required this.id,
    required this.orderId,
    required this.userName,
    required this.userNumber,
    required this.writerName,
    required this.writerFirebaseUid,
    required this.issueTitle,
    required this.description,
    required this.status,
    required this.priority,
    required this.time,
    required this.color,
    required this.fileName,
    required this.filePageCount,
    required this.totalOrderAmount,
    required this.writerSubmissionVersion,
    required this.readByAdmin,
  });

  factory DisputeModel.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    final int disputeId = _toInt(data["disputeId"], fallback: 0);
    final int orderId = _toInt(data["orderId"], fallback: 0);

    final String reason = data["reason"]?.toString() ?? "Dispute Raised";
    final String messagePreview =
        data["messagePreview"]?.toString() ?? "No message provided.";

    final String disputeStatus =
        data["disputeStatus"]?.toString().toUpperCase() ?? "OPEN";

    final String cleanStatus = _cleanStatus(disputeStatus);
    final String priority = _getPriority(data, reason);
    final Color color = _getColor(cleanStatus, priority);

    final String writerUid = data["writerFirebaseUid"]?.toString() ?? "";

    return DisputeModel(
      documentId: doc.id,
      rawDisputeId: disputeId,
      rawOrderId: orderId,
      id: disputeId == 0 ? "#DSP${doc.id}" : "#DSP$disputeId",
      orderId: orderId == 0 ? "#ORD-" : "#ORD$orderId",
      userName: data["userName"]?.toString() ?? "Unknown User",
      userNumber: data["userNumber"]?.toString() ?? "-",
      writerName: data["writerName"]?.toString().isNotEmpty == true
          ? data["writerName"].toString()
          : "Writer Assigned",
      writerFirebaseUid: writerUid,
      issueTitle: reason,
      description: messagePreview,
      status: cleanStatus,
      priority: priority,
      time: _formatTime(data["createdAtTimestamp"]),
      color: color,
      fileName: data["fileName"]?.toString() ?? "-",
      filePageCount: _toInt(data["filePageCount"], fallback: 0),
      totalOrderAmount: _toInt(data["totalOrderAmount"], fallback: 0),
      writerSubmissionVersion:
      data["writerSubmissionVersion"]?.toString() ?? "-",
      readByAdmin: data["readByAdmin"] == true,
    );
  }

  static int _toInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;

    if (value is int) return value;

    return int.tryParse(value.toString()) ?? fallback;
  }

  static String _cleanStatus(String status) {
    final upper = status.toUpperCase();

    if (upper == "RESOLVED") {
      return "Resolved";
    }

    if (upper == "OPEN" || upper == "ADMIN_REVIEWING") {
      return "Open";
    }

    if (upper == "WAITING_USER_REPLY") {
      return "Waiting User";
    }

    if (upper == "WAITING_WRITER_REPLY") {
      return "Waiting Writer";
    }

    if (upper == "REVISION_REQUESTED") {
      return "Revision Requested";
    }

    return upper.replaceAll("_", " ");
  }

  static String _getPriority(Map<String, dynamic> data, String reason) {
    final existingPriority = data["priority"]?.toString();

    if (existingPriority != null && existingPriority.trim().isNotEmpty) {
      return existingPriority;
    }

    final lowerReason = reason.toLowerCase();

    if (lowerReason.contains("payment") ||
        lowerReason.contains("wrong") ||
        lowerReason.contains("fake")) {
      return "Urgent";
    }

    if (lowerReason.contains("incomplete") ||
        lowerReason.contains("poor") ||
        lowerReason.contains("quality")) {
      return "High";
    }

    return "Normal";
  }

  static Color _getColor(String status, String priority) {
    if (status == "Resolved") {
      return Colors.greenAccent;
    }

    if (priority == "Urgent") {
      return Colors.redAccent;
    }

    if (priority == "High") {
      return Colors.orange;
    }

    return Colors.orangeAccent;
  }

  static String _formatTime(dynamic value) {
    try {
      if (value == null) {
        return "Not available";
      }

      DateTime dateTime;

      if (value is Timestamp) {
        dateTime = value.toDate();
      } else {
        dateTime = DateTime.parse(value.toString());
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return "Just now";
      }

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} min ago";
      }

      if (difference.inHours < 24) {
        return "${difference.inHours} hr ago";
      }

      if (difference.inDays == 1) {
        return "Yesterday";
      }

      return DateFormat("dd MMM yyyy, hh:mm a").format(dateTime);
    } catch (e) {
      return value?.toString() ?? "Not available";
    }
  }
}