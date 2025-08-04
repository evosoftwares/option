import 'package:geocoding/geocoding.dart';

class LocationData {

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
    this.postalCode,
  });

  factory LocationData.fromPlacemark(
    double lat,
    double lng,
    Placemark placemark,
  ) {
    return LocationData(
      latitude: lat,
      longitude: lng,
      address: _buildAddress(placemark),
      neighborhood: placemark.subLocality,
      city: placemark.locality,
      state: placemark.administrativeArea,
      postalCode: placemark.postalCode,
    );
  }
  final double latitude;
  final double longitude;
  final String address;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? postalCode;

  static String _buildAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    
    if (placemark.name?.isNotEmpty == true && 
        placemark.name != placemark.street) {
      parts.add(placemark.name!);
    }
    
    return parts.join(', ');
  }

  String get fullAddress {
    final parts = <String>[address];
    
    if (neighborhood?.isNotEmpty == true) {
      parts.add(neighborhood!);
    }
    
    if (city?.isNotEmpty == true && state?.isNotEmpty == true) {
      parts.add('$city - $state');
    }
    
    return parts.join(', ');
  }

  String get shortAddress {
    return address.length > 50 ? '${address.substring(0, 47)}...' : address;
  }

  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? postalCode,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode ^ address.hashCode;
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $address)';
  }
}