import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;

  const SideBar({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
  });

  static const List<String> pages = [
    "HOME",
    "LEVELS",
    "SUBJECTS",
    "MCQ QUESTIONS",
    "T/F QUESTIONS",
    "FILL QUESTIONS",
    "USERS",
    "REVIEWS",
    "VIEW COMPLAINTS",
  ];

  static const List<IconData> icons = [
    Icons.home,
    Icons.stacked_bar_chart,
    Icons.menu_book,
    Icons.radio_button_checked,
    Icons.check_box,
    Icons.edit,
    Icons.people_alt_rounded,
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
        widget.onItemSelected(index);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8A4AF0).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.deepPurpleAccent, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              SideBar.icons[index],
              color: isSelected ? Colors.deepPurpleAccent : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              SideBar.pages[index],
              style: TextStyle(
                color: isSelected ? Colors.deepPurpleAccent : Colors.white,
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
      color: const Color(0xFF1A1A1A),
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
