import 'package:flutter/material.dart';
import 'package:project_admin/screen/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://zocmpjizmgscrhudkozy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvY21waml6bWdzY3JodWRrb3p5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYzOTk1NzcsImV4cCI6MjA1MTk3NTU3N30.PlwRSf4PIU2DjbnlkzqQqiZ1SfWo5fxCaKCOdT8biqo',
  );
  runApp(MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: AdminLogin());
  }
}
