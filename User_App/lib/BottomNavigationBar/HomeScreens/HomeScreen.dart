import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen> {
  final Color bgColor = const Color(0xFF020B2D);
  final Color cardColor = const Color(0xFF07143D);
  final Color innerCardColor = const Color(0xFF101B4D);
  final Color orangeColor = const Color(0xffFF6A00);
  final Color purpleColor = const Color(0xFF8D5CFF);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 55,
        backgroundColor: bgColor,
        centerTitle: false,
        title: const Text(
          "HOME",
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 7, bottom: 7),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101B4D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              Positioned(
                right: 13,
                top: 12,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: orangeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello Sachin 👋",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Let's get your handwritten work done.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    heroCard(size),

                    const SizedBox(height: 13),

                    Row(
                      children: [
                        Expanded(
                          child: _quickActionCard(
                            icon: Icons.add_box_rounded,
                            title: "New\nRequest",
                            color: purpleColor,
                            onTap: () {
                              Navigator.pushNamed(context, "/HomeScreen2");
                            },
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _quickActionCard(
                            icon: Icons.receipt_long_rounded,
                            title: "My\nOrders",
                            color: const Color(0xFF2F80ED),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _quickActionCard(
                            icon: Icons.help_rounded,
                            title: "Help\nCenter",
                            color: orangeColor,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    TrustSaftey(),

                    const SizedBox(height: 14),

                    HowItWorks(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget heroCard(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
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
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: purpleColor.withOpacity(0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            "assets/animation/homeAnimation.json",
            height: size.height < 700 ? 85 : size.height * 0.135,
            alignment: Alignment.center,
            animate: true,
            repeat: true,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 5),

          const Text(
            "Get Your Handwritten Work Done",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              height: 1.18,
            ),
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          Text(
            "Assignments, notes, practical files and exam prep.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 12.3,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 13),

          ContinueButton(),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: miniTrustCard(
                  icon: Icons.verified_user_rounded,
                  iconColor: Colors.greenAccent,
                  title: "Secure",
                  subtitle: "Protected payment",
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: miniTrustCard(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: Colors.lightBlueAccent,
                  title: "Verified",
                  subtitle: "Trusted writers",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget miniTrustCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                trackingName(title),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.52),
                    fontSize: 10.2,
                    fontWeight: FontWeight.w500,
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

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        height: 108,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),

            const SizedBox(height: 8),

            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget trackingName(String name) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 11.8,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        overflow: TextOverflow.ellipsis,
      ),
      textAlign: TextAlign.start,
      maxLines: 1,
    );
  }

  Widget HowItWorks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "HOW IT WORKS",
            style: TextStyle(
              fontSize: 17,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
              color: Color(0xff01F702),
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              _stepCircle("1"),
              const SizedBox(width: 10),
              Expanded(
                child: _stepText(
                  "Submit requirement",
                  "Fill details and upload your file.",
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              _stepCircle("2"),
              const SizedBox(width: 10),
              Expanded(
                child: _stepText(
                  "Writer accepts",
                  "A verified writer picks your work.",
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              _stepCircle("3"),
              const SizedBox(width: 10),
              Expanded(
                child: _stepText(
                  "Review work",
                  "Accept work or request changes.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepCircle(String number) {
    return Container(
      height: 31,
      width: 31,
      decoration: BoxDecoration(
        color: const Color(0xff01B920),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xff01B920).withOpacity(0.30),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _stepText(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            overflow: TextOverflow.ellipsis,
          ),
          textAlign: TextAlign.start,
          maxLines: 1,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.3,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.58),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget TrustSaftey() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "TRUST & SAFETY",
            style: TextStyle(
              fontSize: 17,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
              color: Color(0xff01B920),
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),

          const SizedBox(height: 13),

          _trustRow(
            icon: Icons.lock_rounded,
            iconColor: const Color(0xffF4C430),
            title: "Escrow payment",
            subtitle: "Pay safely after writer is found.",
          ),

          const Divider(height: 18),

          _trustRow(
            icon: Icons.verified_rounded,
            iconColor: const Color(0xff2196F3),
            title: "Verified writers",
            subtitle: "Trusted handwriting experts.",
          ),

          const Divider(height: 18),

          _trustRow(
            icon: Icons.privacy_tip_rounded,
            iconColor: const Color(0xff01B920),
            title: "Privacy protected",
            subtitle: "Your files and info are safe.",
          ),
        ],
      ),
    );
  }

  Widget _trustRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.14),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.2,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.start,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.2,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(0.58),
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.start,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget ContinueButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: () {
        Navigator.pushNamed(context, "/HomeScreen2");
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xffFF7A00),
              Color(0xffFF4D00),
            ],
          ),
          borderRadius: BorderRadius.circular(13.0),
          boxShadow: [
            BoxShadow(
              color: orangeColor.withOpacity(0.30),
              blurRadius: 13,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8.0),
            const Flexible(
              child: Text(
                "Create Request",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8.0),
            Image.asset(
              'assets/images/arrowright.png',
              width: 19.0,
              height: 19.0,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}