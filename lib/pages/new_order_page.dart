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
  
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerEmailController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _pickupAddressController = TextEditingController();
  final TextEditingController _deliveryAddressController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _saveToApi = true;

  @override
  void initState() {
    super.initState();

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
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final orderCode = 'PED-NEW-${timestamp.toString().substring(7)}';

      /// CRIAÇÃO DO PEDIDO CORRETA
      final newOrder = Order(
        code: orderCode,
        pickupDate: _pickupDateController.text,          // <-- AGORA VEM CERTO
        expectedDelivery: _deliveryDateController.text,  // <-- ENTREGA
        pickupAddress: _pickupAddressController.text,
        pickupLat: -23.5505,
        pickupLng: -46.6333,
        deliveryAddress: _deliveryAddressController.text,
        deliveryLat: -23.5616,
        deliveryLng: -46.6559,
        customerName: _customerNameController.text,
        phone: _customerPhoneController.text,
        email: _customerEmailController.text,
      );

      /// SALVA LOCALMENTE
      await AppDatabase.instance.addOrder(newOrder);

      /// TENTA SALVAR NA API (opcional)
      if (_saveToApi) {
        try {
          final apiOrder = OrderApiModel(
            id: 0,
            title: 'Pedido $orderCode',
            body: 'Cliente: ${_customerNameController.text}\n'
                'Endereço de entrega: ${_deliveryAddressController.text}',
            userId: 1,
          );
          await _apiService.createOrder(apiOrder);
        } catch (apiError) {
          print("API error (ignorado): $apiError");
        }
      }

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
        title: const Text("Novo Pedido"),
        backgroundColor: const Color(0xFFF6984A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isSubmitting ? null : _createOrder,
            icon: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.check),
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
            const Text(
              'Informações do Cliente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Nome completo *',
                prefixIcon: Icon(Icons.person, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Digite o nome' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _customerEmailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                prefixIcon: Icon(Icons.email, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) =>
                  value == null || !value.contains('@') ? 'Email inválido' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _customerPhoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone *',
                prefixIcon: Icon(Icons.phone, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Digite o telefone' : null,
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

            TextFormField(
              controller: _pickupAddressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Endereço de retirada *',
                prefixIcon: Icon(Icons.location_on, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Digite o endereço' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _pickupDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Data de retirada *',
                prefixIcon: Icon(Icons.calendar_today, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onTap: () => _selectDate(context, _pickupDateController),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _deliveryAddressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Endereço de entrega *',
                prefixIcon: Icon(Icons.flag, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Digite o endereço' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _deliveryDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Data de entrega *',
                prefixIcon: Icon(Icons.calendar_today, color: Color(0xFFF6984A)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onTap: () => _selectDate(context, _deliveryDateController),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Checkbox(
                  value: _saveToApi,
                  activeColor: const Color(0xFFF6984A),
                  onChanged: (v) => setState(() => _saveToApi = v ?? true),
                ),
                const Text("Salvar pedido na API"),
              ],
            ),

            const SizedBox(height: 24),

            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _createOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF6984A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Criar Pedido"),
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
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFF6984A),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      controller.text = _formatDate(picked);
    }
  }
}
