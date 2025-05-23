import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_edventure/screen/leaderboard.dart';
import 'package:user_edventure/screen/login.dart';
import 'package:user_edventure/screen/subject.dart';
import 'package:user_edventure/screen/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final supabase = Supabase.instance.client;
  Future<Map<String, dynamic>?>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response =
          await supabase
              .from('tbl_user')
              .select()
              .eq('id', supabase.auth.currentUser!.id)
              .single();
      return response;
    }
    return null;
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Profile()),
      );
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeaderboardPage()),
      );
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  Future<void> _showUserProfile() async {
    final userData = await _userDataFuture;
    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found! Please log in.")),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[900]!, Colors.black87],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 60, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                userData['user_name'] ?? "Unknown User",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent,
                  fontFamily: 'ComicSans',
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Email : ${userData['user_email']}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.purpleAccent,
                  fontFamily: 'ComicSans',
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "DOB : ${userData['user_dob'] ?? 'Not Set'}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.purpleAccent,
                  fontFamily: 'ComicSans',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await supabase.auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'ComicSans',
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardSize = screenWidth * 0.3;

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.home, size: 35, color: Colors.white),
        backgroundColor: Colors.purple[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 35, color: Colors.white),
            onPressed: _showUserProfile,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[900]!, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: 300,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple[900]!.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/njn.png',
                            width: 300,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: FutureBuilder<Map<String, dynamic>?>(
                              future: _userDataFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.purpleAccent,
                                    ),
                                  );
                                }
                                final userName =
                                    snapshot.data?['user_name'] ?? 'User';
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Hey $userName!",
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'ComicSans',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Ready for Your Next Quest?",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.purple[200],
                                        fontFamily: 'ComicSans',
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CategoryCard(image: "assets/test.jpg", size: cardSize),
                        CategoryCard(
                          image: "assets/english.jpg",
                          size: cardSize,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CategoryCard(
                          image: "assets/maths.avif",
                          size: cardSize,
                        ),
                        CategoryCard(image: "assets/test.jpg", size: cardSize),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CategoryCard(
                          image: "assets/english.jpg",
                          size: cardSize,
                        ),
                        CategoryCard(
                          image: "assets/maths.avif",
                          size: cardSize,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded),
            label: "Leaderboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black87,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontFamily: 'ComicSans'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'ComicSans'),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String image;
  final double size;

  const CategoryCard({super.key, required this.image, required this.size});

  void _showQuestionTypeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[900]!, Colors.black87],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Question Type",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent,
                  fontFamily: 'ComicSans',
                ),
              ),
              const SizedBox(height: 20),
              _buildQuestionTypeButton(context, "True/False", "TF"),
              const SizedBox(height: 10),
              _buildQuestionTypeButton(context, "Multiple Choice (MCQ)", "MCQ"),
              const SizedBox(height: 10),
              _buildQuestionTypeButton(context, "Fill in the Blanks", "FILL"),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionTypeButton(
    BuildContext context,
    String label,
    String type,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubjectPage(type: type)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'ComicSans',
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showQuestionTypeDialog(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: Colors.black54,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.asset(image, height: size, width: size, fit: BoxFit.cover),
              Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple[900]!.withOpacity(0.5),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
