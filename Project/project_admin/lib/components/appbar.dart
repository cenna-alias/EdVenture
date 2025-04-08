import 'package:flutter/material.dart';

class Appbar1 extends StatelessWidget {
  final Function(bool) onToggleSidebar;
  final bool isSidebarVisible;

  const Appbar1({
    super.key,
    required this.onToggleSidebar,
    required this.isSidebarVisible,
  });

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A), // Deep black
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              color: const Color(0xFF8A4AF0), // Purple
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate to Login Page
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text(
                'Logout',
                style: TextStyle(color: const Color(0xFFF06292)), // Soft pink for contrast
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Deep black
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        onToggleSidebar(!isSidebarVisible);
                      },
                      icon: Icon(
                        isSidebarVisible ? Icons.menu_open : Icons.menu,
                        color: const Color(0xFF8A4AF0), // Purple
                        size: 30,
                      ),
                    ),
                    Text(
                      "EdVenture",
                      style: TextStyle(
                        color: const Color(0xFF8A4AF0), // Purple
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _showLogoutDialog(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  Icon(Icons.person, color: const Color(0xFF8A4AF0)), // Purple
                  SizedBox(width: 10),
                  Text(
                    "Admin",
                    style: TextStyle(
                      color: const Color(0xFF8A4AF0), // Purple
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}