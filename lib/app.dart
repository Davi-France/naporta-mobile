import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/order_details_page.dart';
import 'pages/new_order_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Na Porta',
      theme: ThemeData(
        primaryColor: const Color(0xFFF6984A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF6984A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6984A),
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/details': (context) => const OrderDetailsPage(),
        '/new-order': (context) => const NewOrderPage(),
      },
    );
  }
}