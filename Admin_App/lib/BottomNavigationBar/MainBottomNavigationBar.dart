import 'package:adminlikhwao/BottomNavigationBar/Dashboard.dart';
import 'package:adminlikhwao/BottomNavigationBar/Disputes/Disputes.dart';
import 'package:adminlikhwao/BottomNavigationBar/Orders/Orders.dart';
import 'package:adminlikhwao/BottomNavigationBar/Users.dart';
import 'package:flutter/material.dart';

class Mainbottomnavigationbar extends StatefulWidget {
  const Mainbottomnavigationbar({super.key});

  @override
  State<Mainbottomnavigationbar> createState() =>
      _MainbottomnavigationbarState();
}

class _MainbottomnavigationbarState extends State<Mainbottomnavigationbar> {
  int currentIndex = 0;
  final List<Widget> screens = [Dashboard(),Orders(), Disputes(),  Users()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.note_add), label: "Orders"),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: "Disputes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle_sharp),
            label: "Users",
          ),
        ],
      ),
    );
  }
}
