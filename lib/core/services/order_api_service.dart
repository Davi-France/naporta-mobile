// lib/core/services/order_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderApiModel {
  final int id;
  final String title;
  final String body;
  final int userId;

  OrderApiModel({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    return OrderApiModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'userId': userId,
    };
  }
}

class OrderApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<OrderApiModel>> fetchOrders({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/posts?_page=$page&_limit=$limit'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => OrderApiModel.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar pedidos: ${response.statusCode}');
    }
  }

  // NOVO: Criar pedido na API
  Future<OrderApiModel> createOrder(OrderApiModel order) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 201) {
      return OrderApiModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao criar pedido: ${response.statusCode}');
    }
  }

  // NOVO: Atualizar pedido na API
  Future<OrderApiModel> updateOrder(int id, OrderApiModel order) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 200) {
      return OrderApiModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao atualizar pedido: ${response.statusCode}');
    }
  }

  Future<void> deleteOrder(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/posts/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar pedido: ${response.statusCode}');
    }
  }
}