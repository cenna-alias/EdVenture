import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_edventure/main.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    //   try {
    //     // First, verify the old password by attempting to sign in
    //     final response = await supabase.auth.signInWithPassword(
    //       email: supabase.auth.currentUser!.email!,
    //       password: _oldPasswordController.text,
    //     );

    //     if (response.user == null) {
    //       throw Exception('Current password is incorrect');
    //     }

    //     // If sign in was successful, update the password
    //     await supabase.auth.updateUser(
    //       UserAttributes(
    //         password: _newPasswordController.text,
    //       ),
    //     );

    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Password changed successfully'),
    //         backgroundColor: Colors.green,
    //         behavior: SnackBarBehavior.floating,
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(10),
    //         ),
    //       ),
    //     );

    //     Navigator.pop(context);
    //   } catch (e) {
    //     print('Error changing password: $e');
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(e.toString().contains('incorrect')
    //             ? 'Current password is incorrect'
    //             : 'Failed to change password'),
    //         backgroundColor: Colors.red,
    //         behavior: SnackBarBehavior.floating,
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(10),
    //         ),
    //       ),
    //     );
    //   } finally {
    //     setState(() {
    //       isLoading = false;
    //     });
    //   }
    // }
    try {
      // First, verify the old password by attempting to sign in
      final response = await supabase.auth.signInWithPassword(
        email: supabase.auth.currentUser!.email!,
        password: _oldPasswordController.text,
      );

      if (response.user == null) {
        throw Exception('Current password is incorrect');
      }

      // If sign in was successful, update the password
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      await supabase
          .from('tbl_user')
          .update({'user_password': _newPasswordController.text})
          .eq('id', supabase.auth.currentUser!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('incorrect')
                ? 'Current password is incorrect'
                : 'Failed to change password',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue.shade400,
        elevation: 0,
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      size: 50,
                      color: Colors.blue.shade400,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Security',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                _buildPasswordField(
                  'Current Password',
                  _oldPasswordController,
                  Icons.lock_outline,
                  _obscureOldPassword,
                  () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                _buildPasswordField(
                  'New Password',
                  _newPasswordController,
                  Icons.lock,
                  _obscureNewPassword,
                  () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                _buildPasswordField(
                  'Confirm New Password',
                  _confirmPasswordController,
                  Icons.lock,
                  _obscureConfirmPassword,
                  () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Change Password',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Password Tips',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Use at least 8 characters\n• Include uppercase and lowercase letters\n• Add numbers and special characters\n• Avoid using personal information',
                        style: GoogleFonts.poppins(
                          color: Colors.blue.shade800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool obscureText,
    VoidCallback onToggle, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.blue.shade400),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.blue.shade400,
            ),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        style: GoogleFonts.poppins(),
        validator: validator,
      ),
    );
  }
}
