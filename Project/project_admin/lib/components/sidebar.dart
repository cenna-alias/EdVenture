import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;

  const SideBar({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex, // Receive selected index from parent
  });

  static const List<String> pages = [
    "HOME",
    // "ACTIVITY",
    "LEVEL",
    "SUBJECT",
    "MCQ QUESTIONS",
    "T/F QUESTIONS",
    "FILL QUESTIONS",
    "USER",
    // "REPORT",
    "REVIEW",
    "VIEW COMPLAINT",
  ];

  static const List<IconData> icons = [
    Icons.home,
    // Icons.sports_esports,
    Icons.stacked_bar_chart,
    Icons.menu_book,
    Icons.radio_button_checked,
    Icons.check_box,
    Icons.edit,
    Icons.person,
    // Icons.insert_chart,
    Icons.rate_review,
    Icons.feedback,
  ];

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Widget _buildMenuItem(int index) {
    final isSelected = widget.selectedIndex == index;

    return InkWell(
      onTap: () {
        widget.onItemSelected(index); // Notify parent widget
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.yellowAccent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.yellowAccent.shade700, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              SideBar.icons[index],
              color: isSelected ? Colors.yellowAccent.shade700 : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              SideBar.pages[index],
              style: TextStyle(
                color: isSelected ? Colors.yellowAccent.shade700 : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      width: 250,
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: SideBar.pages.length,
              itemBuilder: (context, index) => _buildMenuItem(index),
            ),
          ),
        ],
      ),
    );
  }
}
