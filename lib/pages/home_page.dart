import 'package:flutter/material.dart';
import '../core/database/app_database.dart';
import '../core/models/order.dart';
import '../core/services/order_api_service.dart';
import 'new_order_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Order> _orders = [];
  bool _isLoading = false;
  bool _hasError = false;
  final OrderApiService _apiService = OrderApiService();
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _initApp();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    await AppDatabase.instance.init();
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Tenta API primeiro
      final apiOrders = await _apiService.fetchOrders(page: _page);
      
      if (apiOrders.isEmpty) {
        _hasMore = false;
      } else {
        // Converte e salva localmente
        final orders = apiOrders.map(_convertApiOrder).toList();
        await _saveToLocalDatabase(orders);
        
        setState(() {
          _orders.addAll(orders);
          _page++;
        });
      }
    } catch (e) {
      print('API Error: $e');
      // Fallback para dados locais
      final localOrders = AppDatabase.instance.getOrders(offset: _orders.length);
      
      if (localOrders.isEmpty && _orders.isEmpty) {
        setState(() => _hasError = true);
      } else {
        setState(() => _orders.addAll(localOrders));
        _hasMore = false;
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Order _convertApiOrder(OrderApiModel apiOrder) {
    return Order(
      code: 'PED-${apiOrder.id.toString().padLeft(3, '0')}',
      expectedDelivery: _generateDeliveryDate(apiOrder.id),
      pickupAddress: 'Rua ${apiOrder.title.split(' ').first}, 100',
      pickupLat: -23.5505,
      pickupLng: -46.6333,
      deliveryAddress: 'Av. ${apiOrder.title.split(' ').last}, 500',
      deliveryLat: -23.5616,
      deliveryLng: -46.6559,
      customerName: 'Cliente ${apiOrder.userId}',
      phone: '(11) 9${apiOrder.id}${apiOrder.id}${apiOrder.id}${apiOrder.id}-${apiOrder.id}${apiOrder.id}${apiOrder.id}${apiOrder.id}',
      email: 'cliente${apiOrder.userId}@email.com',
    );
  }

  String _generateDeliveryDate(int id) {
    final days = id % 30 + 1;
    final date = DateTime.now().add(Duration(days: days));
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  Future<void> _saveToLocalDatabase(List<Order> orders) async {
    for (var order in orders) {
      await AppDatabase.instance.addOrder(order);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadOrders();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _orders.clear();
      _page = 1;
      _hasMore = true;
    });
    await _loadOrders();
  }

  Future<void> _createNewOrder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewOrderPage()),
    );
    
    if (result != null && result is Order) {
      // Adiciona o novo pedido na lista
      setState(() {
        _orders.insert(0, result);
      });
      
      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido ${result.code} criado com sucesso!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          // HEADER - 18% da tela
          Container(
            height: screenHeight * 0.18,
            color: const Color(0xFFF6984A),
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo/Ícone + Título no canto esquerdo
                Row(
                  children: [
                    const Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Meus Pedidos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Botão "Novo pedido" no canto direito
                ElevatedButton(
                  onPressed: _createNewOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFF6984A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Novo pedido',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contador de pedidos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: const Color(0xFFF5F5F5),
            child: Row(
              children: [
                Icon(
                  _hasError ? Icons.warning : Icons.info_outline,
                  color: _hasError ? Colors.orange : const Color(0xFFF6984A),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _hasError && _orders.isEmpty
                      ? 'Sem conexão - Dados locais'
                      : '${_orders.length} pedidos encontrados',
                  style: TextStyle(
                    color: _hasError ? Colors.orange : const Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // LISTA DE PEDIDOS
          Expanded(
            child: _buildOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    if (_hasError && _orders.isEmpty) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: const Color(0xFFF6984A),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: _orders.isEmpty && _isLoading
            ? _buildLoadingState()
            : ListView.builder(
                controller: _scrollController,
                itemCount: _orders.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _orders.length) {
                    return _buildLoadingMore();
                  }
                  return _buildOrderItem(_orders[index]);
                },
              ),
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/details', arguments: order),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6984A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Color(0xFFF6984A),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Previsão: ${order.expectedDelivery}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.deliveryAddress,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCCCCCC),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: Colors.grey[200],
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Container(
                      width: 180,
                      height: 12,
                      color: Colors.grey[200],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFF6984A)),
              )
            : const Text(
                'Todos os pedidos carregados',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Sem conexão com a internet',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Conecte-se para carregar os pedidos',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF6984A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}