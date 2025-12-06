// lib/core/api/address_api_service.dart
class AddressApiService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  Future<AddressModel> getAddressByCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanCep.length != 8) {
      throw Exception('CEP inválido');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/$cleanCep/json/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data.containsKey('erro') && data['erro'] == true) {
        throw Exception('CEP não encontrado');
      }

      return AddressModel.fromJson(data);
    } else {
      throw Exception('Erro ao buscar CEP: ${response.statusCode}');
    }
  }

  Future<List<AddressModel>> searchAddress(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/${Uri.encodeComponent(query)}/json/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      
      if (data is List) {
        return data.map((json) => AddressModel.fromJson(json)).toList();
      } else if (data is Map && data.containsKey('erro')) {
        throw Exception('Endereço não encontrado');
      }
      
      return [];
    } else {
      throw Exception('Erro na busca: ${response.statusCode}');
    }
  }
}

class AddressModel {
  final String cep;
  final String street;
  final String neighborhood;
  final String city;
  final String state;

  AddressModel({
    required this.cep,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      cep: json['cep'] ?? '',
      street: json['logradouro'] ?? '',
      neighborhood: json['bairro'] ?? '',
      city: json['localidade'] ?? '',
      state: json['uf'] ?? '',
    );
  }

  String get formattedAddress {
    return '$street, $neighborhood, $city - $state';
  }
}