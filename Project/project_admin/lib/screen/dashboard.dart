import 'package:flutter/material.dart';
import 'package:project_admin/components/appbar.dart';
import 'package:project_admin/components/sidebar.dart';
import 'package:project_admin/screen/activity.dart';
import 'package:project_admin/screen/category.dart';
import 'package:project_admin/screen/level.dart';
import 'package:project_admin/screen/user.dart';
import 'package:project_admin/screen/report.dart';
import 'package:project_admin/screen/review.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Activity(),
    Category(),
    Level(),
    User(),
    Report(),
    Review(),
  ];

  void onSidebarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Row(
          children: [
            Expanded(
                flex: 1, child: SideBar(onItemSelected: onSidebarItemTapped)),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Appbar1(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _pages[_selectedIndex],
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
