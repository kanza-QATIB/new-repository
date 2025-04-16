import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatelessWidget {
  final emailController = TextEditingController();

  void sendResetEmail(BuildContext context) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(
      emailController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('E-mail de réinitialisation envoyé !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Réinitialiser le mot de passe")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            ElevatedButton(
              onPressed: () => sendResetEmail(context),
              child: Text("Envoyer"),
            ),
          ],
        ),
      ),
    );
  }
}