import 'package:flutter/material.dart';

class Appbar1 extends StatelessWidget {
  final Function(bool) onToggleSidebar;
  final bool isSidebarVisible;

  const Appbar1({
    super.key,
    required this.onToggleSidebar,
    required this.isSidebarVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.black,
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
                        color: Colors.yellowAccent.shade700,
                        size: 30,
                      ),
                    ),
                    Text(
                      "EdVenture",
                      style: TextStyle(
                        color: Colors.yellowAccent.shade700,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.person, color: Colors.yellowAccent.shade700),
              SizedBox(width: 10),
              Text(
                "Admin",
                style: TextStyle(color: Colors.yellowAccent.shade700),
              ),
              SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }
}
