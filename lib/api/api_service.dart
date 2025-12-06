// lib/core/api/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Interceptor para logging
  ApiService() {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String endpoint, dynamic data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tempo de conexão esgotado';
      case DioExceptionType.sendTimeout:
        return 'Tempo de envio esgotado';
      case DioExceptionType.receiveTimeout:
        return 'Tempo de recebimento esgotado';
      case DioExceptionType.badResponse:
        return 'Erro na resposta: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Requisição cancelada';
      case DioExceptionType.unknown:
        return 'Erro de conexão: ${error.message}';
      default:
        return 'Erro desconhecido';
    }
  }
}