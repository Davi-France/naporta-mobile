import 'package:hive/hive.dart';
import '../models/order.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Box<Order>? _box;
  static const String _boxName = 'orders';

  Future<void> init() async {
    try {
      _box = await Hive.openBox<Order>(_boxName);

      if (_box!.isEmpty) {
        await _seedData();
      }
    } catch (e) {
      print('Erro ao inicializar banco de dados: $e');
      // Tenta criar o box novamente
      _box = await Hive.openBox<Order>(_boxName);
    }
  }

  List<Order> getOrders({int offset = 0, int limit = 10}) {
    if (_box == null) return [];
    
    final allOrders = _box!.values.toList();
    
    // Paginação para scroll infinito
    if (offset >= allOrders.length) return [];
    
    final end = offset + limit;
    return allOrders.sublist(
      offset,
      end > allOrders.length ? allOrders.length : end,
    );
  }

  Order? getOrderByCode(String code) {
  try {
    return _box?.values.firstWhere(
      (order) => order.code == code,
    );
  } catch (e) {
    return null;
  }
}

  Future<void> addOrder(Order order) async {
    await _box?.add(order);
  }

  Future<void> updateOrder(int key, Order order) async {
    await _box?.put(key, order);
  }

  Future<void> deleteOrder(int key) async {
    await _box?.delete(key);
  }

  Future<void> clearAll() async {
    await _box?.clear();
  }

  int get totalOrders => _box?.length ?? 0;

  Future<void> _seedData() async {
    // Dados mais completos para teste
    final orders = [
      Order(
        code: 'PED-001',
        expectedDelivery: '02/03 às 13:30',
        pickupAddress: 'Rua das Flores, 123 - Centro',
        pickupLat: -23.55052,
        pickupLng: -46.633308,
        deliveryAddress: 'Av. Paulista, 1578 - Bela Vista',
        deliveryLat: -23.56168,
        deliveryLng: -46.65591,
        customerName: 'João Silva',
        phone: '11 99999-9999',
        email: 'joao@example.com',
      ),
      Order(
        code: 'PED-002',
        expectedDelivery: '03/03 às 15:00',
        pickupAddress: 'Rua Augusta, 1000 - Consolação',
        pickupLat: -23.55111,
        pickupLng: -46.65770,
        deliveryAddress: 'Rua Oscar Freire, 200 - Cerqueira César',
        deliveryLat: -23.55888,
        deliveryLng: -46.67222,
        customerName: 'Maria Santos',
        phone: '11 98888-8888',
        email: 'maria@example.com',
      ),
      Order(
        code: 'PED-003',
        expectedDelivery: '04/03 às 10:00',
        pickupAddress: 'Av. Rebouças, 3000 - Pinheiros',
        pickupLat: -23.55944,
        pickupLng: -46.69111,
        deliveryAddress: 'Rua Haddock Lobo, 1000 - Jardins',
        deliveryLat: -23.56333,
        deliveryLng: -46.66111,
        customerName: 'Pedro Oliveira',
        phone: '11 97777-7777',
        email: 'pedro@example.com',
      ),
      // Adicione mais pedidos para testar scroll infinito
      for (int i = 4; i <= 20; i++)
        Order(
          code: 'PED-${i.toString().padLeft(3, '0')}',
          expectedDelivery: '${i+2}/03 às ${9 + i % 8}:${i % 2 == 0 ? '00' : '30'}',
          pickupAddress: 'Rua Exemplo, $i${i}${i} - Bairro ${i}',
          pickupLat: -23.55052 + (i * 0.001),
          pickupLng: -46.633308 + (i * 0.001),
          deliveryAddress: 'Av. Teste, ${i * 100} - Centro ${i}',
          deliveryLat: -23.56168 + (i * 0.001),
          deliveryLng: -46.65591 + (i * 0.001),
          customerName: 'Cliente ${i}',
          phone: '11 9${i}${i}${i}${i}-${i}${i}${i}${i}',
          email: 'cliente$i@example.com',
        ),
    ];

    await _box?.addAll(orders);
  }
}