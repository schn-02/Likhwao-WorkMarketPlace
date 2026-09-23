import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);

  bool isAvailableForOrders = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    String userName = user?.displayName ?? "Writer";
    String userEmail = user?.email ?? "No email";
    String userPhone = user?.phoneNumber ?? "Phone not added";

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            profileTopHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                child: Column(
                  children: [
                    profileMainCard(
                      userName: userName,
                      userEmail: userEmail,
                    ),

                    profileStatsCard(),



                    payoutDetailsCard(),

                    verificationSecurityCard(
                      userEmail: userEmail,
                      userPhone: userPhone,
                    ),

                    quickActionsCard(),

                    logoutCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Manage your account and work details",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              print("Settings clicked");
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget profileMainCard({
    required String userName,
    required String userEmail,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: profileCardDecoration(),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              print("Profile image clicked");
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 82,
                  width: 82,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE8FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: purpleColor,
                    size: 52,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: purpleColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    verifiedWriterChip(),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  userEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F8EF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                "Available for New Orders",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Transform.scale(
                      scale: 0.82,
                      child: Switch(
                        value: isAvailableForOrders,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            isAvailableForOrders = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    profileMiniInfo(
                      Icons.star_rounded,
                      Colors.orange,
                      "4.8 Rating",
                    ),
                    const SizedBox(width: 12),
                    profileMiniInfo(
                      Icons.assignment_turned_in_rounded,
                      purpleColor,
                      "126 Orders",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget verifiedWriterChip() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        print("Verified writer clicked");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE8FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.verified_user_rounded,
              color: purpleColor,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              "Verified",
              style: TextStyle(
                color: purpleColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileMiniInfo(
      IconData icon,
      Color color,
      String title,
      ) {
    return Flexible(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          print("$title clicked");
        },
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 17,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileStatsCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: profileCardDecoration(),
      child: Row(
        children: [
          profileStatItem(
            Icons.account_balance_wallet_rounded,
            Colors.green,
            const Color(0xFFE9F8EF),
            "Total Earnings",
            "₹12,450",
          ),
          profileDivider(),
          profileStatItem(
            Icons.check_circle_rounded,
            Colors.blue,
            const Color(0xFFEAF3FF),
            "Completed",
            "126",
          ),
          profileDivider(),
          profileStatItem(
            Icons.pending_actions_rounded,
            Colors.orange,
            const Color(0xFFFFF2D9),
            "In Progress",
            "4",
          ),
          profileDivider(),
          profileStatItem(
            Icons.schedule_rounded,
            purpleColor,
            const Color(0xFFEDE8FF),
            "Review",
            "2",
          ),
        ],
      ),
    );
  }

  Widget profileStatItem(
      IconData icon,
      Color iconColor,
      Color iconBgColor,
      String title,
      String value,
      ) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          print("$title clicked");
        },
        child: Column(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryColor.withOpacity(0.55),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: iconColor,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileDivider() {
    return Container(
      height: 58,
      width: 1,
      color: Colors.grey.withOpacity(0.16),
    );
  }


  Widget payoutDetailsCard() {
    return sectionCard(
      title: "Payout Details",
      icon: Icons.account_balance_wallet_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: infoBox(
                  Icons.currency_rupee_rounded,
                  "Available Balance",
                  "₹1,200",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    print("Withdraw clicked");
                  },
                  child: Container(
                    height: 68,
                    decoration: BoxDecoration(
                      color: purpleColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                        SizedBox(width: 7),
                        Text(
                          "Withdraw",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: infoBox(
                  Icons.account_balance_rounded,
                  "Bank Account",
                  "HDFC •••• 4587",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: infoBox(
                  Icons.verified_rounded,
                  "Status",
                  "Verified",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget verificationSecurityCard({
    required String userEmail,
    required String userPhone,
  }) {
    return sectionCard(
      title: "Verification & Security",
      icon: Icons.security_rounded,
      child: Column(
        children: [
          infoRow(
            Icons.phone_android_rounded,
            "Phone Verified",
            userPhone,
            Colors.green,
          ),
          const SizedBox(height: 10),
          infoRow(
            Icons.email_outlined,
            "Email Verified",
            userEmail,
            Colors.green,
          ),
          const SizedBox(height: 10),
          infoRow(
            Icons.badge_outlined,
            "ID Proof Submitted",
            "Aadhaar Card",
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget quickActionsCard() {
    return sectionCard(
      title: "Quick Actions",
      icon: Icons.flash_on_rounded,
      child: Column(
        children: [
          actionRow(
            Icons.person_outline_rounded,
            "Edit Profile",
                () {
              print("Edit Profile clicked");
            },
          ),
          actionRow(
            Icons.currency_rupee_rounded,
            "My Earnings",
                () {
              print("My Earnings clicked");
            },
          ),
          actionRow(
            Icons.notifications_none_rounded,
            "Notifications",
                () {
              print("Notifications clicked");
            },
          ),
          actionRow(
            Icons.help_outline_rounded,
            "Help & Support",
                () {
              print("Help Support clicked");
            },
          ),
          actionRow(
            Icons.privacy_tip_outlined,
            "Terms & Privacy",
                () {
              print("Terms Privacy clicked");
            },
          ),
        ],
      ),
    );
  }

  Widget logoutCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () async {
        await _signout();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/login");
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE9EC),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.red.withOpacity(0.16),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red.shade600,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.red.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: profileCardDecoration(),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              print("$title clicked");
            },
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE8FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: purpleColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget infoBox(
      IconData icon,
      String title,
      String value,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        print("$title clicked");
      },
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 72,
        ),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.withOpacity(0.12),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: purpleColor,
              size: 22,
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.55),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget infoRow(
      IconData icon,
      String title,
      String value,
      Color statusColor,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        print("$title clicked");
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: purpleColor,
              size: 21,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
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
            Icon(
              Icons.check_circle_rounded,
              color: statusColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget actionRow(
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.10),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F7FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: purpleColor,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: primaryColor.withOpacity(0.45),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration profileCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.065),
          blurRadius: 17,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }
}

Future<void> _signout() async {
  await FirebaseAuth.instance.signOut();
}