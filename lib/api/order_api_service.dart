// lib/core/api/order_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  final http.Client _client;

  OrderApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<OrderApiModel>> fetchOrders({int page = 1, int limit = 10}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/posts?_page=$page&_limit=$limit'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => OrderApiModel.fromJson(json)).toList();
    } else {
      throw ApiException(
        message: 'Falha ao carregar pedidos',
        statusCode: response.statusCode,
      );
    }
  }

  Future<OrderApiModel> fetchOrderDetails(int id) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/posts/$id'),
    );

    if (response.statusCode == 200) {
      return OrderApiModel.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        message: 'Falha ao carregar detalhes do pedido',
        statusCode: response.statusCode,
      );
    }
  }

  Future<OrderApiModel> createOrder(OrderApiModel order) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 201) {
      return OrderApiModel.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        message: 'Falha ao criar pedido',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> updateOrder(int id, OrderApiModel order) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toJson()),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Falha ao atualizar pedido',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> deleteOrder(int id) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/posts/$id'),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Falha ao deletar pedido',
        statusCode: response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}

// Model para a API
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
      id: json['id'],
      title: json['title'],
      body: json['body'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
    };
  }

  // Converter para sua Order local
  Order toLocalOrder() {
    return Order(
      code: 'PED-${id.toString().padLeft(3, '0')}',
      expectedDelivery: 'Daqui a 2 dias',
      pickupAddress: 'Rua ${title.split(' ').first}, 123',
      pickupLat: -23.55052 + (id * 0.001),
      pickupLng: -46.633308 + (id * 0.001),
      deliveryAddress: 'Av. ${title.split(' ').last}, 456',
      deliveryLat: -23.56168 + (id * 0.001),
      deliveryLng: -46.65591 + (id * 0.001),
      customerName: 'Cliente $userId',
      phone: '11 9${id}${id}${id}${id}-${id}${id}${id}${id}',
      email: 'cliente$userId@example.com',
    );
  }
}