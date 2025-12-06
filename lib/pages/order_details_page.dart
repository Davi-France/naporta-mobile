import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/models/order.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Order _order;
  late MapController _mapController;

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
    // Centraliza o mapa depois de construir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerMap();
    });
  }

  void _centerMap() {
    final pickup = LatLng(_order.pickupLat, _order.pickupLng);
    final delivery = LatLng(_order.deliveryLat, _order.deliveryLng);
    
    // Calcula o ponto médio
    final center = LatLng(
      (pickup.latitude + delivery.latitude) / 2,
      (pickup.longitude + delivery.longitude) / 2,
    );
    
    // Zoom que mostra ambos os pontos
    _mapController.move(center, 13);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final pickupPoint = LatLng(_order.pickupLat, _order.pickupLng);
    final deliveryPoint = LatLng(_order.deliveryLat, _order.deliveryLng);

    return Scaffold(
      body: Column(
        children: [
          // HEADER - 18% da tela
          Container(
            height: screenHeight * 0.18,
            color: const Color(0xFFF6984A),
            child: Stack(
              children: [
                // Botão voltar
                Positioned(
                  left: 20,
                  top: 50,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                // Título do pedido
                Positioned(
                  left: 72,
                  top: 50,
                  child: Text(
                    _order.code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // MAPA REAL - 35% da tela
          Container(
            height: screenHeight * 0.35,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: pickupPoint,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // Mapa base OpenStreetMap
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.naportamobile',
                ),

                // Marcador de RETIRADA (laranja)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pickupPoint,
                      width: 80,
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6984A),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'RETIRADA',
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

                    // Marcador de ENTREGA (verde)
                    Marker(
                      point: deliveryPoint,
                      width: 80,
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'ENTREGA',
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
                  ],
                ),

                // LINHA DA ROTA (conectando os pontos)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [pickupPoint, deliveryPoint],
                      color: const Color(0xFFF6984A).withOpacity(0.8),
                      strokeWidth: 4,
                      borderStrokeWidth: 2,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // LEGENDA DO MAPA
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMapLegend(
                  color: const Color(0xFFF6984A),
                  label: 'Ponto de Retirada',
                ),
                const SizedBox(width: 20),
                _buildMapLegend(
                  color: Colors.green,
                  label: 'Ponto de Entrega',
                ),
              ],
            ),
          ),

          // INFORMAÇÕES DA ENTREGA
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // SAÍDA (Pickup)
                  _buildDeliveryStep(
                    icon: Icons.local_shipping,
                    title: 'Saindo de:',
                    address: _order.pickupAddress,
                    date: _order.expectedDelivery,
                  ),

                  // LINHA VERTICAL
                  Container(
                    margin: const EdgeInsets.only(left: 24),
                    width: 2,
                    height: 40,
                    color: const Color(0xFFF6984A),
                  ),

                  // CHEGADA (Delivery)
                  _buildDeliveryStep(
                    icon: Icons.flag,
                    title: 'Chegando em:',
                    address: _order.deliveryAddress,
                    date: _order.expectedDelivery,
                  ),

                  const SizedBox(height: 30),

                  // DADOS DO PEDIDO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dados do Pedido',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Código:', _order.code),
                        _buildInfoRow('Cliente:', _order.customerName),
                        _buildInfoRow('Telefone:', _order.phone),
                        _buildInfoRow('Email:', _order.email),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryStep({
    required IconData icon,
    required String title,
    required String address,
    required String date,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF6984A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Data: $date',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}