import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_edventure/screen/changepassword.dart';
import 'package:user_edventure/screen/complaints.dart';
import 'package:user_edventure/screen/editprofile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      final response =
          await supabase.from('tbl_user').select().eq('id', userId).single();

      setState(() {
        userData = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body:
          userData == null
              ? const Center(child: CircularProgressIndicator())
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade700, Colors.white],
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Information',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildInfoRow(
                              icon: Icons.person,
                              label: 'Username',
                              value: userData!['user_name'] ?? 'N/A',
                            ),
                            _buildInfoRow(
                              icon: Icons.family_restroom,
                              label: 'Parent Name',
                              value: userData!['parent_name'] ?? 'N/A',
                            ),
                            _buildInfoRow(
                              icon: Icons.cake,
                              label: 'Date of Birth',
                              value: userData!['user_dob'] ?? 'N/A',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          _buildButton(
                            context: context,
                            title: 'Edit Profile',
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfile(),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 10),
                          _buildButton(
                            context: context,
                            title: 'Change Password',
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const ChangePassword(),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 10),
                          _buildButton(
                            context: context,
                            title: 'My Complaints',
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Complaints(),
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String title,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
