import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      final apiOrders = await _apiService.fetchOrders(page: _page);

      if (apiOrders.isEmpty) {
        _hasMore = false;
      } else {
        final orders = apiOrders.map(_convertApiOrder).toList();
        await _saveToLocalDatabase(orders);

        setState(() {
          _orders.addAll(orders);
          _page++;
        });
      }
    } catch (e) {
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
      pickupDate: _generateDeliveryDate(apiOrder.id),
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
      setState(() {
        _orders.insert(0, result);
      });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: screenHeight * 0.15,
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 12,
            ),
            color: const Color(0xFFF6984A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                    'assets/images/logo.png',
                    height: 60,
                  ),
                ElevatedButton(
                  onPressed: _createNewOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF555555),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: const BorderSide(color: Color(0xFF555555)),
                    ),
                  ),
                  child: const Text(
                    'Novo pedido',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Pedidos',
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Expanded(child: _buildOrderList()),
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
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _orders.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _orders.length) {
            return _buildLoadingMore();
          }
          return _buildOrderItem(_orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/details', arguments: order),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.code,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Previsão de entrega em ${order.expectedDelivery}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF555555),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFFF6984A)),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text(
        'Erro ao carregar pedidos',
        style: TextStyle(
          color: Color(0xFF555555),
          fontSize: 16,
        ),
      ),
    );
  }
}
