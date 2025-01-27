import 'package:flutter/material.dart';
import 'package:project_admin/screen/dashboard.dart';

class SideBar extends StatefulWidget {
  final Function(int) onItemSelected;
  const SideBar({super.key, required this.onItemSelected});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final List<String> pages = [
    "ACTIVITY",
    "CATEGORY",
    "LEVEL",
    "USER",
    "REPORT",
    "REVIEW",
  ];
  final List<IconData> icons = [
    Icons.sports_esports,
    Icons.category,
    Icons.stacked_bar_chart,
    Icons.person,
    Icons.insert_chart,
    Icons.rate_review,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Adding image at the top
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 8, bottom: 10),
                child: Image.asset(
                  'assets/org.webp', // Replace with your image path
                  width: 110,
                  height: 110,
                ),
              ),
              ListView.builder(
                  padding: const EdgeInsets.only(top: 10, left: 5),
                  shrinkWrap: true,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        widget.onItemSelected(index);
                      },
                      leading: Icon(icons[index], color: Colors.black),
                      title: Text(pages[index],
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    );
                  }),
            ],
          ),
          // Logout link styled consistently
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminHome()),
              );
            },
            leading: Icon(Icons.logout, size: 30, color: Colors.black),
            // title: Text(
            //   "LOGOUT",
            //   style: TextStyle(
            //       color: Colors.black,
            //       fontSize: 15,
            //       fontWeight: FontWeight.bold),
            // ),
          ),
        ],
      ),
    );
  }
}
