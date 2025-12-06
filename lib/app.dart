import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/order_details_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Na Porta',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/details': (context) => const OrderDetailsPage(),
      },
    );
  }
}
