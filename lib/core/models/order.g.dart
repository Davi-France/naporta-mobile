// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 0;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order(
      code: fields[0] as String,
      expectedDelivery: fields[1] as String,
      pickupAddress: fields[2] as String,
      pickupLat: fields[3] as double,
      pickupLng: fields[4] as double,
      deliveryAddress: fields[5] as String,
      deliveryLat: fields[6] as double,
      deliveryLng: fields[7] as double,
      customerName: fields[8] as String,
      phone: fields[9] as String,
      email: fields[10] as String,
      pickupDate: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.expectedDelivery)
      ..writeByte(2)
      ..write(obj.pickupAddress)
      ..writeByte(3)
      ..write(obj.pickupLat)
      ..writeByte(4)
      ..write(obj.pickupLng)
      ..writeByte(5)
      ..write(obj.deliveryAddress)
      ..writeByte(6)
      ..write(obj.deliveryLat)
      ..writeByte(7)
      ..write(obj.deliveryLng)
      ..writeByte(8)
      ..write(obj.customerName)
      ..writeByte(9)
      ..write(obj.phone)
      ..writeByte(10)
      ..write(obj.email)
      ..writeByte(11)
      ..write(obj.pickupDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
