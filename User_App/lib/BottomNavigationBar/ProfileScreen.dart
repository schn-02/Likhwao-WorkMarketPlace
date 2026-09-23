import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF020B2D),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF020B2D),
        centerTitle: false,
        title: const Text(
          "PROFILE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            letterSpacing: 4,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
          child: Column(
            children: [
              profileHeader(user),

              const SizedBox(height: 18),

              profileStats(),

              const SizedBox(height: 18),

              accountInfo(user),

              const SizedBox(height: 18),

              menuSection(),

              const SizedBox(height: 18),

              logoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileHeader(User? user) {
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
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8D5CFF),
                      Color(0xFF4B1AB8),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8D5CFF).withOpacity(0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    "assets/images/user.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Positioned(
                right: 2,
                bottom: 5,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xffFF6A00),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF07184A),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            user?.displayName?.isNotEmpty == true
                ? user!.displayName.toString()
                : "USER",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          Text(
            user?.email?.isNotEmpty == true
                ? user!.email.toString()
                : "user@likhwao.com",
            style: TextStyle(
              color: Colors.white.withOpacity(0.60),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xff23C552).withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xff23C552).withOpacity(0.35),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Color(0xff7CFF9B),
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  "Verified User",
                  style: TextStyle(
                    color: Color(0xff7CFF9B),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget profileStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF07143D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: statItem(
              icon: Icons.receipt_long_rounded,
              number: "12",
              title: "Orders",
              color: const Color(0xFF8D5CFF),
            ),
          ),
          verticalDivider(),
          Expanded(
            child: statItem(
              icon: Icons.hourglass_bottom_rounded,
              number: "3",
              title: "Active",
              color: const Color(0xffFFB000),
            ),
          ),
          verticalDivider(),
          Expanded(
            child: statItem(
              icon: Icons.check_circle_rounded,
              number: "7",
              title: "Done",
              color: const Color(0xff23C552),
            ),
          ),
        ],
      ),
    );
  }

  Widget statItem({
    required IconData icon,
    required String number,
    required String title,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          number,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.70),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget verticalDivider() {
    return Container(
      height: 48,
      width: 1,
      color: Colors.white.withOpacity(0.12),
    );
  }

  Widget accountInfo(User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07143D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Account Info"),

          const SizedBox(height: 14),

          infoTile(
            icon: Icons.person_rounded,
            title: "Full Name",
            value: user?.displayName?.isNotEmpty == true
                ? user!.displayName.toString()
                : "Sachin Rawat",
            color: const Color(0xFF8D5CFF),
          ),

          const SizedBox(height: 12),

          infoTile(
            icon: Icons.email_rounded,
            title: "Email Address",
            value: user?.email?.isNotEmpty == true
                ? user!.email.toString()
                : "Not available",
            color: const Color(0xff2F80ED),
          ),

          const SizedBox(height: 12),

          infoTile(
            icon: Icons.phone_android_rounded,
            title: "Phone Number",
            value: user?.phoneNumber?.isNotEmpty == true
                ? user!.phoneNumber.toString()
                : "Not added",
            color: const Color(0xff23C552),
          ),
        ],
      ),
    );
  }

  Widget infoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF101B4D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.48),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withOpacity(0.35),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget menuSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07143D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Quick Settings"),

          const SizedBox(height: 14),

          menuTile(
            icon: Icons.edit_document,
            title: "Edit Profile",
            subtitle: "Update your personal details",
            color: const Color(0xFF8D5CFF),
            onTap: () {},
          ),

          menuTile(
            icon: Icons.receipt_long_rounded,
            title: "My Orders",
            subtitle: "View active and completed orders",
            color: const Color(0xff2F80ED),
            onTap: () {},
          ),

          menuTile(
            icon: Icons.payment_rounded,
            title: "Payment History",
            subtitle: "Check your payment records",
            color: const Color(0xffFFB000),
            onTap: () {},
          ),

          menuTile(
            icon: Icons.support_agent_rounded,
            title: "Help & Support",
            subtitle: "Get support for your order",
            color: const Color(0xff23C552),
            onTap: () {},
          ),

          menuTile(
            icon: Icons.privacy_tip_rounded,
            title: "Privacy & Safety",
            subtitle: "Manage account safety",
            color: const Color(0xffFF6A00),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFF101B4D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.48),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.35),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget logoutButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        await _signout();

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, "/login");
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF07143D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xffff4d4d).withOpacity(0.55),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: Color(0xffff4d4d),
              size: 23,
            ),
            SizedBox(width: 10),
            Text(
              "Logout",
              style: TextStyle(
                color: Color(0xffff4d4d),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _signout() async {
  await FirebaseAuth.instance.signOut();
}