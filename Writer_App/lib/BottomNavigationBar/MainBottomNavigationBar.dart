import 'package:flutter/material.dart';
import 'package:likho/BottomNavigationBar/InboxScreen.dart';

import 'HomeScreen.dart';
import 'OrderScreens/OrdersScreen.dart';
import 'ProfileScreen.dart';

class Mainbottomnavigationbar extends StatefulWidget {
  const Mainbottomnavigationbar({super.key});

  @override
  State<Mainbottomnavigationbar> createState() => _MainbottomnavigationbarState();
}

class _MainbottomnavigationbarState extends State<Mainbottomnavigationbar> {

  int _currentIndex =0;

  final List<Widget> _screens =[

      Ordersscreen(),
    Inboxscreen(),
    Profilescreen()

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index){
          setState(() {
            _currentIndex=index;
          });
        },
        type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.reorder_sharp) , label: "Orders"),
            BottomNavigationBarItem(icon: Icon(Icons.message) , label: "Inbox"),
            BottomNavigationBarItem(icon: Icon(Icons.person) , label: "profile")
          ],
      ),
    );
  }
}
