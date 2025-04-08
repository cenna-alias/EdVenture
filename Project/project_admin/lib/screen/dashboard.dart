import 'package:flutter/material.dart';
import 'package:project_admin/components/appbar.dart';
import 'package:project_admin/components/sidebar.dart';
import 'package:project_admin/screen/add_question.dart';
import 'package:project_admin/screen/complaints.dart';
import 'package:project_admin/screen/fillquestion.dart';
import 'package:project_admin/screen/level.dart';
import 'package:project_admin/screen/subject.dart';
import 'package:project_admin/screen/tfquestion.dart';
import 'package:project_admin/screen/user.dart';
import 'package:project_admin/screen/review.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;
  bool _isSidebarVisible = true;

  final List<Widget> _pages = [
    Center(
      child: Image.asset(
        'assets/bg.jpg',
        width: 500,
        height: 500,
      ),
    ),
    Level(),
    Subject(),
    AddQuestion(),
    Tfquestion(),
    Fillquestion(),
    User(),
    Review(),
    AdminComplaints(),
  ];

  void onSidebarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void toggleSidebar(bool isVisible) {
    setState(() {
      _isSidebarVisible = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          Appbar1(
            onToggleSidebar: toggleSidebar,
            isSidebarVisible: _isSidebarVisible,
          ),
          Expanded(
            child: Row(
              children: [
                if (_isSidebarVisible)
                  Expanded(
                    flex: 1,
                    child: SideBar(
                      onItemSelected: onSidebarItemTapped,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                Expanded(
                  flex: _isSidebarVisible ? 5 : 6,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _pages[_selectedIndex],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
