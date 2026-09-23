  import 'dart:convert';
  
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:likhwao/BottomNavigationBar/InboxScreens/Work_Review.dart';
  import 'package:likhwao/BottomNavigationBar/InboxScreens/ChatListScreen.dart';
  import 'package:likhwao/Model/WriterChatListModel.dart';
import 'package:likhwao/Provider/ChatListProvider.dart';
import 'package:provider/provider.dart';
  
  import '../../ApiConfig/apiConfig.dart';
  
  class Inboxscreen extends StatefulWidget {
    const Inboxscreen({super.key});
  
    @override
    State<Inboxscreen> createState() => _InboxscreenState();
  }
  
  class _InboxscreenState extends State<Inboxscreen> {
    List<Writerchatlistmodel> chatList = [];
    late Chatlistprovider provider;

  
    bool isLoading = false;
  
    final Color bgColor = const Color(0xFF020B2D);
    final Color cardColor = const Color(0xFF07143D);
    final Color innerCardColor = const Color(0xFF101B4D);
    final Color orangeColor = const Color(0xffFF6A00);
    final Color purpleColor = const Color(0xFF7B3FF2);
  
    @override
    void initState() {
      super.initState();
      fetchChatListDataApi();

      WidgetsBinding.instance.addPostFrameCallback((_){

        provider = context.read<Chatlistprovider>();

        provider.addListener(_refreshListner);
      });
    }

     void _refreshListner()
     {

       if(provider.shouldRefresh)
         {
           provider.refreshCompleted();

           fetchChatListDataApi();
         }

     }
    @override
    void dispose() {

      provider.removeListener(_refreshListner);
      super.dispose();
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 52,
          backgroundColor: bgColor,
          centerTitle: false,
          titleSpacing: 14,
          title: const Text(
            "INBOX",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minHeight: 42,
                    minWidth: 42,
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    height: 8,
                    width: 8,
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
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const SizedBox(height: 4),
  
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
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
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8D5CFF),
                          Color(0xFF5B2DCE),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.55),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    tabs: const [
                      Tab(
                        height: 40,
                        iconMargin: EdgeInsets.only(bottom: 2),
                        icon: Icon(Icons.chat_bubble_outline_rounded, size: 17),
                        text: "Chat",
                      ),
                      Tab(
                        height: 40,
                        iconMargin: EdgeInsets.only(bottom: 2),
                        icon: Icon(Icons.description_outlined, size: 17),
                        text: "Work/Review",
                      ),
                    ],
                  ),
                ),
  
                const SizedBox(height: 10),
  
  
  
                const SizedBox(height: 10),
  
                Expanded(
                  child: isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: orangeColor,
                      strokeWidth: 2.4,
                    ),
                  )
                      : TabBarView(
                    children: [
                      Container(
                        color: bgColor,
                        child: Chatlistscreen(order: chatList ,
                          onRefresh :fetchChatListDataApi
                        ),
                      ),
                      Container(
                        color: bgColor,
                        child: WorkReview(order: chatList),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  
  
    Future<void> fetchChatListDataApi() async {
      try {
        setState(() {
          isLoading = true;
        });
  
        final user = FirebaseAuth.instance.currentUser;
  
        if (user == null) {
          return;
        }
  
        final token = await user.getIdToken(true);
  
        final url = Uri.parse(
          "${apiConfig.baseUrl}/api/user_side/chats/writerList",
        );
  
        final response = await http.get(
          url,
          headers: {
            "Authorization": "Bearer $token",
          },
        );
  
        if (!mounted) return;
  
        if (response.statusCode == 200) {
          final item = jsonDecode(response.body);
  
          setState(() {
            chatList.clear();
  
            for (var data in item) {
              var list = Writerchatlistmodel.fromJson(data);

              print("wfwhbwjbwueqvuvuyvudvq $list" );
              chatList.add(list);
            }


          });
        } else {
          print("CHAT LIST ERROR: ${response.statusCode}");
          print("CHAT LIST BODY: ${response.body}");
        }
      } catch (e) {
        print("CHAT LIST EXCEPTION: $e");
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }