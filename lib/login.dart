import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_st/forgetpassword.dart';
import 'package:app_st/profile_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    if (response.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ViceDoyenProfileScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion')),
      );
    }
  }

  void goToResetPasswordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bandeau artistique en haut
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0D5F7), Color(0xFFD3E5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo fictif
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.school, size: 40, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Bienvenue",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Email field
                  _buildTextField(
                    controller: emailController,
                    hintText: "Email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  _buildTextField(
                    controller: passwordController,
                    hintText: "Mot de passe",
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  // Bouton Se connecter
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C4AB6), // Violet
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Se connecter",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Mot de passe oublié
                  TextButton(
                    onPressed: goToResetPasswordPage,
                    child: Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurpleAccent.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(18),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
