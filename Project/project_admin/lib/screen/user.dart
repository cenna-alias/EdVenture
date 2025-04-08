import 'package:flutter/material.dart';
import 'package:project_admin/main.dart';
import 'package:project_admin/screen/viewscore.dart';
import 'package:google_fonts/google_fonts.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  final Color primaryColor = const Color(0xFF6A1B9A);
  final Color accentColor = const Color(0xFF9C27B0);
  final Color backgroundColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color textColor = const Color(0xFFE0E0E0);
  final Color secondaryTextColor = const Color(0xFFB0B0B0);

  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response =
          await supabase.from('tbl_user').select('*').order('user_name');

      setState(() {
        users = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching users: $e'),
        backgroundColor: Colors.red[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
      ));
    }
  }

  void _navigateToUserScores(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Viewscore(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_alt_rounded,
              color: accentColor,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Activities',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.8), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: accentColor,
                strokeWidth: 3,
              ),
            )
          : users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Users Found',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RefreshIndicator(
                    color: accentColor,
                    backgroundColor: cardColor,
                    onRefresh: fetchUsers,
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 0,
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () =>
                                  _navigateToUserScores(context, user['id']),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: primaryColor,
                                      child: Text(
                                        user['user_name'][0].toUpperCase(),
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user['user_name'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap to view scores',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: accentColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
