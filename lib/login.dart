import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_st/forgetpassword.dart';

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Connecté avec succès')));
      // Ici, navigue vers la page d'accueil ou la page souhaitée après connexion
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur de connexion')));
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
      // Un fond dégradé pour toute la page
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          // SingleChildScrollView permet de scroller en cas de clavier qui remonte
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo universitaire
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/university_logo.png'),
                ),
                SizedBox(height: 20),
                // Nom de l'université
                Text(
                  "Université XYZ",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                // Slogan ou sous-titre
                Text(
                  "Plateforme de gestion académique",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                // Carte contenant le formulaire de connexion
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Champ email
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Champ mot de passe
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Mot de passe",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Bouton de connexion
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: signIn,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Se connecter",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Bouton pour mot de passe oublié
                        TextButton(
                          onPressed: goToResetPasswordPage,
                          child: Text("Mot de passe oublié ?"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
