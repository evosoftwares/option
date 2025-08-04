import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para representar um item do histórico de endereços
class AddressHistoryItem {
  final String id;
  final String address;
  final String? shortName;
  final double latitude;
  final double longitude;
  final DateTime lastUsed;
  final int usageCount;

  const AddressHistoryItem({
    required this.id,
    required this.address,
    this.shortName,
    required this.latitude,
    required this.longitude,
    required this.lastUsed,
    this.usageCount = 1,
  });

  /// Cria uma instância a partir de dados do Firestore
  factory AddressHistoryItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return AddressHistoryItem(
      id: snapshot.id,
      address: data['address'] ?? '',
      shortName: data['shortName'],
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      lastUsed: (data['lastUsed'] as Timestamp).toDate(),
      usageCount: data['usageCount'] ?? 1,
    );
  }

  /// Converte para dados do Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'address': address,
      'shortName': shortName,
      'latitude': latitude,
      'longitude': longitude,
      'lastUsed': Timestamp.fromDate(lastUsed),
      'usageCount': usageCount,
    };
  }

  /// Cria uma cópia com campos atualizados
  AddressHistoryItem copyWith({
    String? id,
    String? address,
    String? shortName,
    double? latitude,
    double? longitude,
    DateTime? lastUsed,
    int? usageCount,
  }) {
    return AddressHistoryItem(
      id: id ?? this.id,
      address: address ?? this.address,
      shortName: shortName ?? this.shortName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressHistoryItem &&
        other.id == id &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(id, address, latitude, longitude);
  }

  @override
  String toString() {
    return 'AddressHistoryItem(id: $id, address: $address, shortName: $shortName, usageCount: $usageCount)';
  }
}