import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../ApiConfig/apiConfig.dart';
import '../../Toast/ToastHelper.dart';
import '../Model/FeedbackRequestModel.dart';

class FeedbackScreen extends StatefulWidget {
  final int orderId;
  final int userId;
  final int writerId;
  final String writerName;

  const FeedbackScreen({
    super.key,
    required this.orderId,
    required this.userId,
    required this.writerId,
    required this.writerName,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final Color bgColor = const Color(0xFF020B2D);
  final Color cardColor = const Color(0xFF07143D);
  final Color innerCardColor = const Color(0xFF101B4D);
  final Color orangeColor = const Color(0xffFF6A00);

  final TextEditingController reviewController = TextEditingController();

  int selectedRating = 0;
  bool isAnonymous = false;
  bool isLoading = false;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        toolbarHeight: 56,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 7, bottom: 7),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: innerCardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          "WRITE FEEDBACK",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _writerCard(),

              const SizedBox(height: 16),

              _sectionTitle("Rate Writer"),
              const SizedBox(height: 10),
              _ratingCard(),

              const SizedBox(height: 16),

              _sectionTitle("Your Review"),
              const SizedBox(height: 10),
              _reviewBox(),

              const SizedBox(height: 12),

              _anonymousTile(),

              const SizedBox(height: 22),

              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _writerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B3FF2), Color(0xFF4B1AB8)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.writerName.isEmpty ? "Writer" : widget.writerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Order #${widget.orderId}",
                  style: const TextStyle(
                    color: Color(0xFFB58CFF),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final int rating = index + 1;
              final bool selected = rating <= selectedRating;

              return InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () {
                  setState(() {
                    selectedRating = rating;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    selected ? Icons.star_rounded : Icons.star_border_rounded,
                    color: selected ? const Color(0xffFFB000) : Colors.white38,
                    size: 38,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            getRatingText(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12.8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: reviewController,
        maxLines: 6,
        minLines: 5,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        cursorColor: orangeColor,
        decoration: InputDecoration(
          hintText: "Write your experience with this writer...",
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.38),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _anonymousTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_off_rounded,
            color: orangeColor,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Submit as anonymous",
              style: TextStyle(
                color: Colors.white.withOpacity(0.82),
                fontSize: 12.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch(
            value: isAnonymous,
            activeColor: orangeColor,
            onChanged: (value) {
              setState(() {
                isAnonymous = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: isLoading ? null : submitFeedback,
      child: Container(
        height: 48,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffFF7A00), Color(0xffFF4D00)],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: orangeColor.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.4,
            ),
          )
              : const Text(
            "Submit Feedback",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  String getRatingText() {
    if (selectedRating == 0) {
      return "Tap star to rate writer";
    }

    if (selectedRating == 1) {
      return "Poor experience";
    }

    if (selectedRating == 2) {
      return "Needs improvement";
    }

    if (selectedRating == 3) {
      return "Average work";
    }

    if (selectedRating == 4) {
      return "Good work";
    }

    return "Excellent work";
  }

  Future<void> submitFeedback() async {
    if (selectedRating == 0) {
      ToastHelper.show("Please select rating", context);
      return;
    }

    final String reviewText = reviewController.text.trim();

    if (reviewText.isEmpty) {
      ToastHelper.show("Please write your review", context);
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ToastHelper.show("User not logged in", context);
        return;
      }

      final token = await user.getIdToken(true);

      final feedbackRequest = FeedbackRequestModel(
        orderId: widget.orderId,
        userId: widget.userId,
        writerId: widget.writerId,
        rating: selectedRating,
        reviewText: reviewText,
        anonymous: isAnonymous,
      );


      final url = Uri.parse(
        "${apiConfig.baseUrl}/api/user_side/feedback/submit",
      );

      print("FEEDBACK TOKEN: $token");
      print("FEEDBACK URL: $url");

      final response = await http.post(
        url,
        headers: {
          "Authorization":"Bearer $token",
          "Content-Type":"application/json",
        },
        body: jsonEncode(feedbackRequest.toJson()),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastHelper.show("Feedback submitted successfully", context);
        Navigator.pop(context, true);
      } else {
        print("Feedback Error: ${response.statusCode}");
        print("Feedback Body: ${response.body}");
        ToastHelper.show("Feedback submit failed", context);
      }
    } catch (e) {
      print("Feedback Exception: $e");

      if (!mounted) return;

      ToastHelper.show("Something went wrong", context);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}