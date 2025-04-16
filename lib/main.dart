import 'package:app_st/getstarted.dart' show GetStartedPage;
import 'package:app_st/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ihcwnyqwdrzntzfjckvb.supabase.co/', // à remplacer
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImloY3dueXF3ZHJ6bnR6Zmpja3ZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3MDI5ODgsImV4cCI6MjA2MDI3ODk4OH0.JLEkBYvAFPkuQJrSxHKnc448A_Hat7XuFFf1G_TqUQk',                 // à remplacer
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Connexion',
      home: GetStartedPage(),
    );
  }
}
