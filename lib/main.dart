import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sijj_provinsi_banten/functions/auth_function.dart';
import 'package:sijj_provinsi_banten/pages/home_page.dart';
import 'package:sijj_provinsi_banten/pages/auth/login_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIJJ Provinsi Banten',
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.user?.token != null) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
