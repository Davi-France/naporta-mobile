import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/models/order.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Order _order;
  late MapController _mapController;
  final double _initialZoom = 12.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Order) {
      _order = args;
    }
    _mapController = MapController();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerMap();
    });
  }

  void _centerMap() {
    final pickup = LatLng(_order.pickupLat, _order.pickupLng);
    final delivery = LatLng(_order.deliveryLat, _order.deliveryLng);
    
    final center = LatLng(
      (pickup.latitude + delivery.latitude) / 2,
      (pickup.longitude + delivery.longitude) / 2,
    );
    
    _mapController.move(center, _initialZoom);
  }

  Future<void> _openNavigationApp(LatLng destination, String label) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${destination.latitude},${destination.longitude}'
      '&travelmode=driving'
      '&dir_action=navigate'
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o aplicativo de navegação'),
        ),
      );
    }
  }

  Marker _buildPickupMarker() {
    final point = LatLng(_order.pickupLat, _order.pickupLng);
    return Marker(
      point: point,
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () => _showLocationInfo(
          point, 
          'Retirada', 
          _order.pickupAddress
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6984A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_shipping,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Text(
                'Retirada',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF6984A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Marker _buildDeliveryMarker() {
    final point = LatLng(_order.deliveryLat, _order.deliveryLng);
    return Marker(
      point: point,
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () => _showLocationInfo(
          point, 
          'Entrega', 
          _order.deliveryAddress
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.flag,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Text(
                'Entrega',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pickupPoint = LatLng(_order.pickupLat, _order.pickupLng);
    final deliveryPoint = LatLng(_order.deliveryLat, _order.deliveryLng);

    return Scaffold(
      body: Column(
        children: [
          // HEADER
          Container(
            height: MediaQuery.of(context).size.height * 0.18,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFF6984A),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _order.code,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Cliente: ${_order.customerName}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'navigate_pickup') {
                          _openNavigationApp(pickupPoint, 'Ponto de retirada');
                        } else if (value == 'navigate_delivery') {
                          _openNavigationApp(deliveryPoint, 'Ponto de entrega');
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'navigate_pickup',
                          child: Row(
                            children: [
                              Icon(Icons.navigation, color: Color(0xFFF6984A)),
                              SizedBox(width: 8),
                              Text('Navegar para retirada'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'navigate_delivery',
                          child: Row(
                            children: [
                              Icon(Icons.flag, color: Color(0xFFF6984A)),
                              SizedBox(width: 8),
                              Text('Navegar para entrega'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // MAPA (OpenStreetMap)
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: pickupPoint,
                initialZoom: _initialZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // Camada de tiles (mapa)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.desafio_mobile',
                ),

                // Polylines (rota)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [pickupPoint, deliveryPoint],
                      color: const Color(0xFFF6984A).withOpacity(0.7),
                      strokeWidth: 4,
                    ),
                  ],
                ),

                // Marcadores
                MarkerLayer(
                  markers: [
                    _buildPickupMarker(),
                    _buildDeliveryMarker(),
                  ],
                ),
              ],
            ),
          ),

          // CONTROLES DO MAPA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openNavigationApp(pickupPoint, 'Retirada'),
                  icon: const Icon(Icons.navigation, size: 16),
                  label: const Text('Para retirada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6984A),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openNavigationApp(deliveryPoint, 'Entrega'),
                  icon: const Icon(Icons.flag, size: 16),
                  label: const Text('Para entrega'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: _centerMap,
                  icon: const Icon(Icons.center_focus_strong),
                  tooltip: 'Centralizar rota',
                ),
              ],
            ),
          ),

          // DETALHES
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // RESUMO DA ROTA
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildRouteInfo(
                            icon: Icons.local_shipping,
                            title: 'Local de Retirada',
                            address: _order.pickupAddress,
                            color: const Color(0xFFF6984A),
                            onNavigate: () => _openNavigationApp(pickupPoint, 'Retirada'),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Icon(
                              Icons.arrow_downward,
                              color: Color(0xFFF6984A),
                              size: 24,
                            ),
                          ),
                          _buildRouteInfo(
                            icon: Icons.flag,
                            title: 'Local de Entrega',
                            address: _order.deliveryAddress,
                            color: Colors.green,
                            onNavigate: () => _openNavigationApp(deliveryPoint, 'Entrega'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // DISTÂNCIA E DURAÇÃO (simulados)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetric(
                            icon: Icons.place,
                            value: '8.5 km',
                            label: 'Distância',
                          ),
                          _buildMetric(
                            icon: Icons.timer,
                            value: '25 min',
                            label: 'Tempo estimado',
                          ),
                          _buildMetric(
                            icon: Icons.calendar_today,
                            value: _order.expectedDelivery,
                            label: 'Previsão',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // INFORMAÇÕES DO CLIENTE
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informações do Cliente',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF555555),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildClientInfo('Nome', _order.customerName),
                          _buildClientInfo('Telefone', _order.phone),
                          _buildClientInfo('Email', _order.email),
                          _buildClientInfo('Código', _order.code),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BOTÕES DE AÇÃO
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchPhoneCall(_order.phone),
                          icon: const Icon(Icons.phone),
                          label: const Text('Ligar'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFF6984A)),
                            foregroundColor: const Color(0xFFF6984A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchEmail(_order.email),
                          icon: const Icon(Icons.email),
                          label: const Text('Email'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.green),
                            foregroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo({
    required IconData icon,
    required String title,
    required String address,
    required Color color,
    required VoidCallback onNavigate,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNavigate,
          icon: Icon(Icons.navigation, color: color),
          tooltip: 'Navegar até este local',
        ),
      ],
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF6984A), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF555555),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildClientInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (label == 'Telefone' || label == 'Email')
            IconButton(
              icon: Icon(
                label == 'Telefone' ? Icons.phone : Icons.email,
                size: 16,
                color: const Color(0xFFF6984A),
              ),
              onPressed: () {
                if (label == 'Telefone') {
                  _launchPhoneCall(value);
                } else {
                  _launchEmail(value);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Future<void> _launchPhoneCall(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível fazer a chamada'),
        ),
      );
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Pedido ${_order.code}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o aplicativo de email'),
        ),
      );
    }
  }

  void _showLocationInfo(LatLng point, String title, String address) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF555555),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              address,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Coordenadas: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openNavigationApp(point, title);
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navegar até aqui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: title == 'Retirada'
                          ? const Color(0xFFF6984A)
                          : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}