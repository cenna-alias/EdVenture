import 'package:flutter/material.dart';
import 'package:project_admin/main.dart';
import 'package:project_admin/screen/viewscore.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
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
        backgroundColor: Colors.redAccent,
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
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text(
          'USERS',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 2,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blueGrey[700]!),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading Users...',
                            style: TextStyle(
                              color: Colors.blueGrey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : users.isEmpty
                      ? Center(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blueGrey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return GestureDetector(
                                onTap: () =>
                                    _navigateToUserScores(context, user['id']),
                                child: Card(
                                  elevation: 5,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.blueGrey[700],
                                          child: Text(
                                            user['user_name'][0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
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
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueGrey[800],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Tap to view scores',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blueGrey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 20,
                                          color: Colors.blueGrey[600],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
