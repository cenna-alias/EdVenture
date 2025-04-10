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
          backgroundColor: Colors.transparent, // Transparent for custom styling
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12), // Sharp, professional corners
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 320, // Slightly wider for a balanced look
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A), // Black background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8A4AF0)
                    .withOpacity(0.3), // Subtle purple border
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirm Logout',
                  style: TextStyle(
                    color: const Color(0xFF8A4AF0), // Purple for title
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(
                    color: Colors.white70, // Light grayish-white for contrast
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white70, // Light grayish-white
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        backgroundColor:
                            const Color(0xFF2A2A2A), // Darker black/gray
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: const Color(0xFFFFFFFF), // White text
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        backgroundColor:
                            const Color(0xFF8A4AF0), // Purple accent
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
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
                        color: const Color(0xFF8A4AF0),
                        size: 30,
                      ),
                    ),
                    Text(
                      "EdVenture",
                      style: TextStyle(
                        color: const Color(0xFF8A4AF0),
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
                  Icon(Icons.person, color: const Color(0xFF8A4AF0)),
                  SizedBox(width: 10),
                  Text(
                    "Admin",
                    style: TextStyle(
                      color: const Color(0xFF8A4AF0),
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
