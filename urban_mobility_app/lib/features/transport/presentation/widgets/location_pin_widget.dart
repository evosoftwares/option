import 'package:flutter/material.dart';

class LocationPinWidget extends StatelessWidget {

  const LocationPinWidget({
    super.key,
    required this.isMoving,
  });
  final bool isMoving;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sombra do pin com blur animado
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isMoving ? 20 : 16,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(isMoving ? 0.2 : 0.3),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: isMoving ? 8 : 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Pin principal
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            Icons.location_pin,
            color: isMoving ? Colors.red[600] : Colors.red[700],
            size: isMoving ? 56 : 52,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
        ),
      ],
    );
  }
}