import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/models/order.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(OrderAdapter());
  
  // Aguarda a inicialização completa
  await Hive.openBox<Order>('orders');
  
  runApp(const App());
}