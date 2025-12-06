import 'package:flutter/material.dart';
import '../core/database/app_database.dart';
import '../core/models/order.dart';
import '../core/services/order_api_service.dart';

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({super.key});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final OrderApiService _apiService = OrderApiService();
  
  // Controladores para os campos do formulário
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerEmailController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _pickupAddressController = TextEditingController();
  final TextEditingController _deliveryAddressController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _saveToApi = true; // Checkbox para salvar na API

  @override
  void initState() {
    super.initState();
    // Preenche datas padrão
    final now = DateTime.now();
    final pickupDate = now.add(const Duration(days: 1));
    final deliveryDate = now.add(const Duration(days: 2));
    
    _pickupDateController.text = _formatDate(pickupDate);
    _deliveryDateController.text = _formatDate(deliveryDate);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _pickupAddressController.dispose();
    _deliveryAddressController.dispose();
    _pickupDateController.dispose();
    _deliveryDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Gera um código único para o pedido
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final orderCode = 'PED-NEW-${timestamp.toString().substring(7)}';

      // Cria o objeto Order
      final newOrder = Order(
        code: orderCode,
        expectedDelivery: _deliveryDateController.text,
        pickupAddress: _pickupAddressController.text,
        pickupLat: -23.5505, // Coordenadas padrão (SP)
        pickupLng: -46.6333,
        deliveryAddress: _deliveryAddressController.text,
        deliveryLat: -23.5616,
        deliveryLng: -46.6559,
        customerName: _customerNameController.text,
        phone: _customerPhoneController.text,
        email: _customerEmailController.text,
      );

      // Salva no banco local
      await AppDatabase.instance.addOrder(newOrder);

      // Se marcado, tenta salvar na API também
      if (_saveToApi) {
        try {
          // Cria um OrderApiModel para enviar à API
          final apiOrder = OrderApiModel(
            id: 0, // API vai gerar novo ID
            title: 'Pedido $orderCode',
            body: 'Cliente: ${_customerNameController.text}\n'
                  'Endereço de entrega: ${_deliveryAddressController.text}',
            userId: 1, // ID de usuário padrão
          );

          await _apiService.createOrder(apiOrder);
        } catch (apiError) {
          // Não impede o salvamento local se a API falhar
          print('API Error (não crítico): $apiError');
        }
      }

      // Navega de volta com sucesso
      Navigator.pop(context, newOrder);

    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao criar pedido: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pedido'),
        backgroundColor: const Color(0xFFF6984A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isSubmitting ? null : _createOrder,
            icon: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.check),
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Informações do Cliente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 20),

            // Campo: Nome do Cliente
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Nome completo *',
                prefixIcon: Icon(Icons.person, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o nome do cliente';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo: Email
            TextFormField(
              controller: _customerEmailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                prefixIcon: Icon(Icons.email, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o email';
                }
                if (!value.contains('@')) {
                  return 'Digite um email válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo: Telefone
            TextFormField(
              controller: _customerPhoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone *',
                prefixIcon: Icon(Icons.phone, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o telefone';
                }
                return null;
              },
            ),

            const SizedBox(height: 30),
            const Text(
              'Informações da Entrega',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 20),

            // Campo: Endereço de Retirada
            TextFormField(
              controller: _pickupAddressController,
              decoration: const InputDecoration(
                labelText: 'Endereço de retirada *',
                prefixIcon: Icon(Icons.location_on, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Rua, número, bairro, cidade',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o endereço de retirada';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo: Data de Retirada
            TextFormField(
              controller: _pickupDateController,
              decoration: const InputDecoration(
                labelText: 'Data de retirada *',
                prefixIcon: Icon(Icons.calendar_today, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _pickupDateController),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecione a data de retirada';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo: Endereço de Entrega
            TextFormField(
              controller: _deliveryAddressController,
              decoration: const InputDecoration(
                labelText: 'Endereço de entrega *',
                prefixIcon: Icon(Icons.flag, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Rua, número, bairro, cidade',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o endereço de entrega';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo: Data de Entrega
            TextFormField(
              controller: _deliveryDateController,
              decoration: const InputDecoration(
                labelText: 'Data de entrega *',
                prefixIcon: Icon(Icons.calendar_today, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _deliveryDateController),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecione a data de entrega';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Checkbox para salvar na API
            Row(
              children: [
                Checkbox(
                  value: _saveToApi,
                  onChanged: (value) {
                    setState(() {
                      _saveToApi = value ?? true;
                    });
                  },
                  activeColor: const Color(0xFFF6984A),
                ),
                const Expanded(
                  child: Text(
                    'Salvar também na nuvem (recomendado)',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Mensagem de erro
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Botão de salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _createOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF6984A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Salvando...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline),
                          SizedBox(width: 8),
                          Text(
                            'Criar Pedido',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF6984A),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = _formatDate(picked);
    }
  }
}