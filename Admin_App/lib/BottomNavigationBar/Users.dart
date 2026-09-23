import 'dart:convert';

import 'package:adminlikhwao/ApiConfig/apiConfig.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  int selectedTab = 0;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  final Color bg = const Color(0xFF07111F);
  final Color card = const Color(0xFF0E1B2E);
  final Color card2 = const Color(0xFF13243A);
  final Color primary = const Color(0xFF4FA3FF);
  final Color textColor = const Color(0xFFF3F7FF);
  final Color subText = const Color(0xFF9FB0C7);
  final Color border = const Color(0xFF22344D);

  final List<String> tabs = const [
    "All",
    "Users",
    "Writers",
    "Blocked",
  ];

  late Future<AdminUserWriterResponse> usersFuture;

  final String baseUrl = "https://likhwaobackend-production.up.railway.app";

  @override
  void initState() {
    super.initState();
    usersFuture = fetchUserWriterDetails();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<AdminUserWriterResponse> fetchUserWriterDetails() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("Admin not logged in");
    }

    final String? token = await currentUser.getIdToken();

    final Uri url = Uri.parse("${apiConfig.baseUrl}/api/admin/details/user-writer");

    final http.Response response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      return AdminUserWriterResponse.fromJson(jsonBody);
    }

    throw Exception("API failed: ${response.statusCode} ${response.body}");
  }

  Future<void> _refreshUsers() async {
    setState(() {
      usersFuture = fetchUserWriterDetails();
    });

    await usersFuture;
  }

  List<AppUserModel> _getAllItems(AdminUserWriterResponse response) {
    final List<AppUserModel> items = [];

    for (final AdminUserResponse user in response.users) {
      items.add(AppUserModel.fromUser(user));
    }

    for (final AdminWriterResponse writer in response.writers) {
      items.add(AppUserModel.fromWriter(writer));
    }

    return items;
  }

  List<AppUserModel> _getFilteredUsers(List<AppUserModel> users) {
    List<AppUserModel> result = users;

    if (selectedTab == 1) {
      result = result.where((u) => u.role.toUpperCase() == "USER").toList();
    } else if (selectedTab == 2) {
      result = result.where((u) => u.role.toUpperCase() == "WRITER").toList();
    } else if (selectedTab == 3) {
      result = result.where((u) => u.isBlocked).toList();
    }

    final String query = searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((u) => u.matchesSearch(query)).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FutureBuilder<AdminUserWriterResponse>(
          future: usersFuture,
          builder: (context, snapshot) {
            final bool isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            if (isLoading) {
              return Column(
                children: [
                  _header(),
                  Expanded(child: _loadingState()),
                ],
              );
            }

            if (snapshot.hasError) {
              return Column(
                children: [
                  _header(),
                  Expanded(child: _errorState(snapshot.error.toString())),
                ],
              );
            }

            final AdminUserWriterResponse response =
                snapshot.data ?? AdminUserWriterResponse.empty();

            final List<AppUserModel> allUsers = _getAllItems(response);
            final List<AppUserModel> filteredUsers =
            _getFilteredUsers(allUsers);

            return RefreshIndicator(
              color: primary,
              backgroundColor: card,
              onRefresh: _refreshUsers,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _header(),
                  const SizedBox(height: 14),
                  _summaryCards(allUsers),
                  const SizedBox(height: 16),
                  _tabs(),
                  const SizedBox(height: 12),
                  _searchBox(),
                  const SizedBox(height: 12),
                  if (filteredUsers.isEmpty)
                    _emptyState()
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: filteredUsers
                            .map<Widget>(
                              (AppUserModel user) => _userCard(user),
                        )
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
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
              "Users",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _refreshUsers();
            },
            child: Icon(Icons.refresh, color: textColor),
          ),
          const SizedBox(width: 14),
          Icon(Icons.person_add_alt_1_outlined, color: textColor),
        ],
      ),
    );
  }

  Widget _summaryCards(List<AppUserModel> users) {
    final int totalUsers =
        users.where((u) => u.role.toUpperCase() == "USER").length;

    final int totalWriters =
        users.where((u) => u.role.toUpperCase() == "WRITER").length;

    final int blocked = users.where((u) => u.isBlocked).length;

    return SizedBox(
      height: 95,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          _summaryCard(
            "Users",
            totalUsers.toString(),
            Icons.person_outline,
            Colors.blueAccent,
          ),
          const SizedBox(width: 10),
          _summaryCard(
            "Writers",
            totalWriters.toString(),
            Icons.edit_outlined,
            Colors.greenAccent,
          ),
          const SizedBox(width: 10),
          _summaryCard(
            "Blocked",
            blocked.toString(),
            Icons.block,
            Colors.redAccent,
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
              onTap: () {
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
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                ),
                cursorColor: primary,
                decoration: InputDecoration(
                  hintText: "Search user, writer, email...",
                  hintStyle: TextStyle(
                    color: subText,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (searchQuery.isNotEmpty)
              InkWell(
                onTap: () {
                  searchController.clear();
                  setState(() {
                    searchQuery = "";
                  });
                },
                child: Icon(Icons.close, color: subText, size: 21),
              )
            else
              Icon(Icons.sort, color: subText, size: 21),
          ],
        ),
      ),
    );
  }

  Widget _userCard(AppUserModel user) {
    final bool isBlocked = user.isBlocked;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _avatarBox(user.name, user.color),
              _smallInfo("ID", user.id),
              _statusChip(
                user.role,
                user.role.toUpperCase() == "WRITER"
                    ? Colors.greenAccent
                    : primary,
              ),
              _statusChip(
                user.status,
                isBlocked ? Colors.redAccent : Colors.greenAccent,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            user.name.isEmpty ? "No Name" : user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.email.isEmpty ? "No email" : user.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subText,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          _detailsBox(user),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _actionButton(
                title: "View Details",
                icon: Icons.visibility_outlined,
                filled: false,
                color: primary,
                onTap: () {
                  // Baad me details page yahan open karenge
                },
              ),
              _actionButton(
                title: isBlocked ? "Unblock" : "Block",
                icon: isBlocked ? Icons.lock_open : Icons.block,
                filled: true,
                color: isBlocked ? Colors.green : Colors.redAccent,
                onTap: () {
                  // Baad me block/unblock API yahan call karenge
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarBox(String name, Color color) {
    String firstLetter = "?";

    if (name.trim().isNotEmpty) {
      firstLetter = name.trim()[0].toUpperCase();
    }

    return Container(
      height: 46,
      width: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        firstLetter,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _detailsBox(AppUserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _infoLine(Icons.phone_outlined, user.phone),
          const SizedBox(height: 8),
          _infoLine(Icons.assignment_outlined, user.orders),
          const SizedBox(height: 8),
          _infoLine(Icons.currency_rupee, user.amount),
          const SizedBox(height: 8),
          _infoLine(Icons.calendar_month_outlined, user.joined),
          const SizedBox(height: 8),
          _infoLine(
            Icons.verified_user_outlined,
            "Email Verified: ${user.emailVerified ? "Yes" : "No"}",
            color: user.emailVerified ? Colors.greenAccent : Colors.orange,
          ),
          const SizedBox(height: 8),
          _infoLine(
            Icons.check_circle_outline,
            "Details Completed: ${user.detailsCompleted ? "Yes" : "No"}",
            color: user.detailsCompleted ? Colors.greenAccent : Colors.orange,
          ),
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

  Widget _statusChip(String status, Color color) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 145),
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
    required Color color,
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
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )
            : OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18, color: color),
          label: FittedBox(
            child: Text(
              title,
              style: TextStyle(color: color),
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: primary,
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: subText, size: 42),
            const SizedBox(height: 12),
            Text(
              "No users found",
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Try another tab or search keyword",
              style: TextStyle(
                color: subText,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
            const SizedBox(height: 12),
            Text(
              "Something went wrong",
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: OutlinedButton(
                onPressed: () {
                  _refreshUsers();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Retry",
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminUserWriterResponse {
  final List<AdminUserResponse> users;
  final List<AdminWriterResponse> writers;

  const AdminUserWriterResponse({
    required this.users,
    required this.writers,
  });

  factory AdminUserWriterResponse.empty() {
    return const AdminUserWriterResponse(
      users: [],
      writers: [],
    );
  }

  factory AdminUserWriterResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> usersJson = json["users"] ?? [];
    final List<dynamic> writersJson = json["writers"] ?? [];

    return AdminUserWriterResponse(
      users: usersJson
          .map((item) => AdminUserResponse.fromJson(
        Map<String, dynamic>.from(item),
      ))
          .toList(),
      writers: writersJson
          .map((item) => AdminWriterResponse.fromJson(
        Map<String, dynamic>.from(item),
      ))
          .toList(),
    );
  }
}

class AdminUserResponse {
  final int id;
  final String firebaseUid;
  final String email;
  final String name;
  final String phoneNumber;
  final String countryCode;
  final String countryName;
  final bool emailVerified;
  final bool detailsCompleted;
  final bool blocked;
  final int totalOrders;
  final int totalSpent;
  final String role;
  final String createdAt;
  final String updatedAt;

  const AdminUserResponse({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.countryCode,
    required this.countryName,
    required this.emailVerified,
    required this.detailsCompleted,
    required this.blocked,
    required this.totalOrders,
    required this.totalSpent,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminUserResponse.fromJson(Map<String, dynamic> json) {
    return AdminUserResponse(
      id: _toInt(json["id"]),
      firebaseUid: _toString(json["firebaseUid"]),
      email: _toString(json["email"]),
      name: _toString(json["name"]),
      phoneNumber: _toString(json["phoneNumber"]),
      countryCode: _toString(json["countryCode"]),
      countryName: _toString(json["countryName"]),
      emailVerified: _toBool(json["emailVerified"]),
      detailsCompleted: _toBool(json["detailsCompleted"]),
      blocked: _toBool(json["blocked"]),
      totalOrders: _toInt(json["totalOrders"]),
      totalSpent: _toInt(json["totalSpent"]),
      role: _toString(json["role"], fallback: "USER"),
      createdAt: _toString(json["createdAt"]),
      updatedAt: _toString(json["updatedAt"]),
    );
  }
}

class AdminWriterResponse {
  final int id;
  final String firebaseUid;
  final String email;
  final String name;
  final String phoneNumber;
  final String countryCode;
  final String countryName;
  final bool emailVerified;
  final bool detailsCompleted;
  final bool blocked;
  final int totalOrders;
  final int totalEarnings;
  final String role;
  final String createdAt;
  final String updatedAt;

  const AdminWriterResponse({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.countryCode,
    required this.countryName,
    required this.emailVerified,
    required this.detailsCompleted,
    required this.blocked,
    required this.totalOrders,
    required this.totalEarnings,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminWriterResponse.fromJson(Map<String, dynamic> json) {
    return AdminWriterResponse(
      id: _toInt(json["id"]),
      firebaseUid: _toString(json["firebaseUid"]),
      email: _toString(json["email"]),
      name: _toString(json["name"]),
      phoneNumber: _toString(json["phoneNumber"]),
      countryCode: _toString(json["countryCode"]),
      countryName: _toString(json["countryName"]),
      emailVerified: _toBool(json["emailVerified"]),
      detailsCompleted: _toBool(json["detailsCompleted"]),
      blocked: _toBool(json["blocked"]),
      totalOrders: _toInt(json["totalOrders"]),
      totalEarnings: _toInt(json["totalEarnings"]),
      role: _toString(json["role"], fallback: "WRITER"),
      createdAt: _toString(json["createdAt"]),
      updatedAt: _toString(json["updatedAt"]),
    );
  }
}

class AppUserModel {
  final String id;
  final int rawId;
  final String firebaseUid;
  final String name;
  final String email;
  final String role;
  final String status;
  final String phone;
  final String countryCode;
  final String countryName;
  final String orders;
  final String amount;
  final String joined;
  final Color color;
  final bool isBlocked;
  final bool emailVerified;
  final bool detailsCompleted;
  final int totalOrders;
  final int totalSpent;
  final int totalEarnings;

  const AppUserModel({
    required this.id,
    required this.rawId,
    required this.firebaseUid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.phone,
    required this.countryCode,
    required this.countryName,
    required this.orders,
    required this.amount,
    required this.joined,
    required this.color,
    required this.isBlocked,
    required this.emailVerified,
    required this.detailsCompleted,
    required this.totalOrders,
    required this.totalSpent,
    required this.totalEarnings,
  });

  factory AppUserModel.fromUser(AdminUserResponse user) {
    final String phone = _formatPhone(user.countryCode, user.phoneNumber);

    return AppUserModel(
      id: "#USR${user.id.toString()}",
      rawId: user.id,
      firebaseUid: user.firebaseUid,
      name: user.name,
      email: user.email,
      role: "User",
      status: user.blocked ? "Blocked" : "Active",
      phone: phone,
      countryCode: user.countryCode,
      countryName: user.countryName,
      orders: "${user.totalOrders} Orders",
      amount: "₹${user.totalSpent}",
      joined: _formatJoined(user.createdAt),
      color: user.blocked ? Colors.redAccent : Colors.blueAccent,
      isBlocked: user.blocked,
      emailVerified: user.emailVerified,
      detailsCompleted: user.detailsCompleted,
      totalOrders: user.totalOrders,
      totalSpent: user.totalSpent,
      totalEarnings: 0,
    );
  }

  factory AppUserModel.fromWriter(AdminWriterResponse writer) {
    final String phone = _formatPhone(writer.countryCode, writer.phoneNumber);

    return AppUserModel(
      id: "#WRT${writer.id.toString()}",
      rawId: writer.id,
      firebaseUid: writer.firebaseUid,
      name: writer.name,
      email: writer.email,
      role: "Writer",
      status: writer.blocked ? "Blocked" : "Active",
      phone: phone,
      countryCode: writer.countryCode,
      countryName: writer.countryName,
      orders: "${writer.totalOrders} Works",
      amount: "₹${writer.totalEarnings}",
      joined: _formatJoined(writer.createdAt),
      color: writer.blocked ? Colors.redAccent : Colors.greenAccent,
      isBlocked: writer.blocked,
      emailVerified: writer.emailVerified,
      detailsCompleted: writer.detailsCompleted,
      totalOrders: writer.totalOrders,
      totalSpent: 0,
      totalEarnings: writer.totalEarnings,
    );
  }

  bool matchesSearch(String query) {
    return id.toLowerCase().contains(query) ||
        rawId.toString().contains(query) ||
        firebaseUid.toLowerCase().contains(query) ||
        name.toLowerCase().contains(query) ||
        email.toLowerCase().contains(query) ||
        role.toLowerCase().contains(query) ||
        status.toLowerCase().contains(query) ||
        phone.toLowerCase().contains(query) ||
        countryCode.toLowerCase().contains(query) ||
        countryName.toLowerCase().contains(query) ||
        orders.toLowerCase().contains(query) ||
        amount.toLowerCase().contains(query) ||
        totalOrders.toString().contains(query) ||
        totalSpent.toString().contains(query) ||
        totalEarnings.toString().contains(query);
  }
}

String _formatPhone(String countryCode, String phoneNumber) {
  final String cc = countryCode.trim();
  final String phone = phoneNumber.trim();

  if (cc.isEmpty && phone.isEmpty) return "Phone: N/A";
  if (cc.isEmpty) return phone;
  if (phone.isEmpty) return cc;

  return "$cc $phone";
}

String _formatJoined(String createdAt) {
  if (createdAt.trim().isEmpty) return "Joined: N/A";

  try {
    final DateTime date = DateTime.parse(createdAt);
    return "Joined ${date.day}/${date.month}/${date.year}";
  } catch (e) {
    return "Joined $createdAt";
  }
}

String _toString(dynamic value, {String fallback = ""}) {
  if (value == null) return fallback;

  final String result = value.toString().trim();

  if (result.isEmpty || result.toLowerCase() == "null") {
    return fallback;
  }

  return result;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();

  return int.tryParse(value.toString()) ?? fallback;
}

bool _toBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;

  final String result = value.toString().trim().toLowerCase();

  if (result == "true") return true;
  if (result == "false") return false;

  return fallback;
}