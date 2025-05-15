import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _parentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  bool _isPasswordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        await supabase.from('tbl_user').insert({
          'user_name': _usernameController.text.trim(),
          'parent_name': _parentController.text.trim(),
          'user_dob': _dobController.text.trim(),
          'user_email': _emailController.text,
          'user_password': _passwordController.text,
          'user_age': _ageController.text,
        });
        await showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                backgroundColor: Colors.black,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/popper.json',
                      width: 200,
                      height: 200,
                      repeat: false,
                      fit: BoxFit.contain,
                      onLoaded: (composition) async {
                        await Future.delayed(composition.duration);
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const Text(
                      "Done!",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Registration failed: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.purple[900]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.how_to_reg, size: 60, color: Colors.yellow),
                const SizedBox(height: 10),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Sign up to get started!",
                  style: TextStyle(fontSize: 16, color: Colors.purple[200]),
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  color: Colors.black.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _usernameController,
                            label: "User name",
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _parentController,
                            label: "Parent name",
                            icon: Icons.family_restroom,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _emailController,
                            label: "Email",
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),
                          _buildPasswordField(),
                          const SizedBox(height: 15),
                          _buildDatePicker(),
                          const SizedBox(height: 15),
                          _buildShowAge(),
                          const SizedBox(height: 25),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[600],
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            onPressed: _registerUser,
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                      Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.purple[300],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple[400]),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[400]!, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.purple[300]),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label cannot be empty";
        }
        if (label == "User name" || label == "Parent name") {
          if (value.trim().length < 3) {
            return "$label must be at least 3 characters";
          }
          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
            return "$label can only contain letters and spaces";
          }
        }
        if (label == "Email") {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value.trim())) {
            return "Please enter a valid email address";
          }
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: Icon(Icons.lock, color: Colors.purple[400]),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.purple[400],
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[400]!, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.purple[300]),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Password cannot be empty";
        }
        if (value.length < 8) {
          return "Password must be at least 8 characters";
        }
        if (!RegExp(
          r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$',
        ).hasMatch(value)) {
          return "Password must contain letters and numbers";
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dobController,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Date of Birth",
        prefixIcon: Icon(Icons.calendar_today, color: Colors.purple[400]),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[400]!, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.purple[300]),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Date of Birth cannot be empty";
        }
        try {
          final dob = DateTime.parse(value);
          final now = DateTime.now();
          final age =
              now.year -
              dob.year -
              (now.month < dob.month ||
                      (now.month == dob.month && now.day < dob.day)
                  ? 1
                  : 0);
          if (age < 7) {
            return "You must be at least 7 years old";
          }
          _ageController.text = age.toString(); 
        } catch (e) {
          return "Invalid date format (use YYYY-MM-DD)";
        }
        return null;
      },
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          String formattedDate =
              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          setState(() {
            _dobController.text = formattedDate;
            final now = DateTime.now();
            int age = now.year - pickedDate.year;
            if (now.month < pickedDate.month ||
                (now.month == pickedDate.month && now.day < pickedDate.day)) {
              age--;
            }
            _ageController.text = age.toString();
          });
        }
      },
    );
  }

  Widget _buildShowAge() {
    return TextFormField(
      controller: _ageController,
      readOnly: true, 
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Age',
        prefixIcon: Icon(Icons.person, color: Colors.purple[400]),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[400]!, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.purple[300]),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Age cannot be empty";
        }
        final age = int.tryParse(value);
        if (age == null || age < 7) {
          return "You must be at least 7 years old";
        }
        return null;
      },
    );
  }
}
