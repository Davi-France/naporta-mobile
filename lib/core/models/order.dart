import 'package:hive/hive.dart';

part 'order.g.dart';
@HiveType(typeId: 0)
class Order extends HiveObject {
  @HiveField(0)
  String code;

  @HiveField(1)
  String expectedDelivery;

  @HiveField(2)
  String pickupAddress;

  @HiveField(3)
  double pickupLat;

  @HiveField(4)
  double pickupLng;

  @HiveField(5)
  String deliveryAddress;

  @HiveField(6)
  double deliveryLat;

  @HiveField(7)
  double deliveryLng;

  @HiveField(8)
  String customerName;

  @HiveField(9)
  String phone;

  @HiveField(10)
  String email;

  @HiveField(11)
  String pickupDate;

  Order({
    required this.code,
    required this.expectedDelivery,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.deliveryAddress,
    required this.deliveryLat,
    required this.deliveryLng,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.pickupDate,
  });
}
