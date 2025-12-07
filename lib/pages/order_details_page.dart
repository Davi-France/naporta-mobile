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
          Container(
            height: screenHeight * 0.18,
            color: const Color(0xFFF6984A),
            child: Stack(
              children: [
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
                Positioned(
                  left: 72,
                  top: 50,
                  child: Text(
                    'Pedido: ${_order.code}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.naportamobile',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: pickupPoint,
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6984A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    Marker(
                      point: deliveryPoint,
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6984A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),

                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [pickupPoint, deliveryPoint],
                      color: const Color(0xFFF6984A),
                      strokeWidth: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6984A),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.directions_car, color: Colors.white, size: 26),
                              ),
                              Container(
                                width: 2,
                                height: 50,
                                color: const Color(0xFFB5B5B5),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saindo de: ${_order.pickupAddress}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _order.pickupDate,
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),


                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6984A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.flag, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chegando em: ${_order.deliveryAddress}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _order.expectedDelivery,
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),


                  const SizedBox(height: 32),

                  Text(
                    _order.code,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF555555),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Cliente',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_order.customerName, style: const TextStyle(fontSize: 16)),
                  Text(_order.email, style: const TextStyle(fontSize: 16)),
                  Text(_order.phone, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
