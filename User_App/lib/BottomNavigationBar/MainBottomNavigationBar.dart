import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:likhwao/BottomNavigationBar/HomeScreens/HomeScreen.dart';
import 'package:likhwao/BottomNavigationBar/InboxScreens/InboxScreen.dart';
import 'package:likhwao/BottomNavigationBar/OrderScreen/OrdersScreen.dart';
import 'package:likhwao/BottomNavigationBar/ProfileScreen.dart';

class Mainbottomnavigationbar extends StatefulWidget {
  const Mainbottomnavigationbar({super.key});

  @override
  State<Mainbottomnavigationbar> createState() => _MainbottomnavigationbarState();
}

class _MainbottomnavigationbarState extends State<Mainbottomnavigationbar> {

  int _currentIndex =0;

  final List<Widget> _screens =[

     Homescreen(),
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
            BottomNavigationBarItem(icon: Icon(Icons.home) , label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.reorder_sharp) , label: "Orders"),
            BottomNavigationBarItem(icon: Icon(Icons.message) , label: "Inbox"),
            BottomNavigationBarItem(icon: Icon(Icons.person) , label: "profile")
          ],
      ),
    );
  }
}
