import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_service.dart';

class PlacePickerFieldComponent extends StatefulWidget {

  const PlacePickerFieldComponent({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.onPlaceSelected,
    this.initialValue,
    this.enabled = true,
  });
  final String hintText;
  final Widget prefixIcon;
  final Function(SelectedPlace) onPlaceSelected;
  final String? initialValue;
  final bool enabled;

  @override
  State<PlacePickerFieldComponent> createState() => _PlacePickerFieldComponentState();
}

class _PlacePickerFieldComponentState extends State<PlacePickerFieldComponent> {
  final TextEditingController _controller = TextEditingController();
  final LocationService _locationService = LocationService();
  List<SelectedPlace> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 3) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = true;
    });

    try {
      final locations = await _locationService.searchLocation(query);
      final List<SelectedPlace> places = [];

      for (final location in locations) {
        try {
          final placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );
          
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            final address = _formatAddress(placemark);
            
            places.add(SelectedPlace(
              name: placemark.name ?? query,
              address: address,
              latitude: location.latitude,
              longitude: location.longitude,
            ));
          }
        } catch (e) {
          // Se falhar ao obter placemark, usar dados básicos
          places.add(SelectedPlace(
            name: query,
            address: 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
            latitude: location.latitude,
            longitude: location.longitude,
          ));
        }
      }

      setState(() {
        _suggestions = places.take(5).toList(); // Limitar a 5 sugestões
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    
    return parts.join(', ');
  }

  void _selectPlace(SelectedPlace place) {
    _controller.text = place.name;
    setState(() {
      _showSuggestions = false;
    });
    widget.onPlaceSelected(place);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            onChanged: _searchPlaces,
            onTap: () {
              if (_suggestions.isNotEmpty) {
                setState(() {
                  _showSuggestions = true;
                });
              }
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              _suggestions = [];
                              _showSuggestions = false;
                            });
                          },
                        )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final place = _suggestions[index];
                return ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.grey,
                    size: 20,
                  ),
                  title: Text(
                    place.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    place.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  onTap: () => _selectPlace(place),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Modelo para representar um lugar selecionado
class SelectedPlace {

  const SelectedPlace({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  factory SelectedPlace.fromCoordinates({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? placeId,
  }) {
    return SelectedPlace(
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      placeId: placeId,
    );
  }
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? placeId;

  @override
  String toString() {
    return 'SelectedPlace(name: $name, address: $address, lat: $latitude, lng: $longitude)';
  }
}