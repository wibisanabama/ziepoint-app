import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'Data Siswa',
      debugShowCheckedModeBanner: false,
      theme: theme.light(),
      home: const LoginPage(),
    );
  }
}
