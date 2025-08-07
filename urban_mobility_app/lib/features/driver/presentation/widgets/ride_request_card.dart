import 'package:flutter/material.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../domain/models/ride_request.dart';

/// Card que exibe uma solicitação de viagem
class RideRequestCard extends StatefulWidget {
  const RideRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
    this.isLoading = false,
  });

  final RideRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isLoading;

  @override
  State<RideRequestCard> createState() => _RideRequestCardState();
}

class _RideRequestCardState extends State<RideRequestCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _countdownController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animação de pulso para chamar atenção
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animação do countdown
    _countdownController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _startAnimations();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _countdownController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeRemaining = widget.request.timeRemaining;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(DesignTokens.spaceMd),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              side: BorderSide(color: DesignTokens.primaryBlue, width: 2),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignTokens.primaryBlue.withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header com countdown
                    _buildHeader(Duration(seconds: timeRemaining)),

                    const SizedBox(height: DesignTokens.spaceMd),

                    // Informações do passageiro
                    _buildPassengerInfo(),

                    const SizedBox(height: DesignTokens.spaceMd),

                    // Detalhes da viagem
                    _buildTripDetails(),

                    const SizedBox(height: DesignTokens.spaceLg),

                    // Botões de ação
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Duration timeRemaining) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceXs),
              decoration: BoxDecoration(
                color: DesignTokens.primaryBlue,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: const Icon(
                Icons.directions_car,
                color: Colors.white,
                size: DesignTokens.iconMd,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            Text(
              'Nova Solicitação',
              style: DesignTokens.headingMedium.copyWith(
                color: DesignTokens.primaryBlue,
              ),
            ),
          ],
        ),
        // Countdown
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceSm,
            vertical: DesignTokens.spaceXs,
          ),
          decoration: BoxDecoration(
            color: timeRemaining.inSeconds <= 3
                ? DesignTokens.errorRed
                : DesignTokens.warningOrange,
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Text(
            '${timeRemaining.inSeconds}s',
            style: DesignTokens.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerInfo() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundLight,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Row(
        children: [
          // Avatar do passageiro
          CircleAvatar(
            radius: 24,
            backgroundColor: DesignTokens.primaryBlue,
            child: Text(
              widget.request.passengerName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          // Informações do passageiro
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.request.passengerName,
                  style: DesignTokens.labelLarge,
                ),
                const SizedBox(height: DesignTokens.space2xs),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: DesignTokens.warningOrange,
                      size: DesignTokens.iconSm,
                    ),
                    const SizedBox(width: DesignTokens.space2xs),
                    Text(
                      widget.request.passengerRating?.toStringAsFixed(1) ??
                          'N/A',
                      style: DesignTokens.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails() {
    return Column(
      children: [
        // Origem e destino
        Row(
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: DesignTokens.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(width: 2, height: 30, color: DesignTokens.textMuted),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: DesignTokens.errorRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(width: DesignTokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Origem', style: DesignTokens.bodySmall),
                  Text(
                    'Lat: ${widget.request.origin.latitude.toStringAsFixed(4)}, '
                    'Lng: ${widget.request.origin.longitude.toStringAsFixed(4)}',
                    style: DesignTokens.bodyMedium,
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  Text('Destino', style: DesignTokens.bodySmall),
                  Text(
                    'Lat: ${widget.request.destination.latitude.toStringAsFixed(4)}, '
                    'Lng: ${widget.request.destination.longitude.toStringAsFixed(4)}',
                    style: DesignTokens.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: DesignTokens.spaceMd),

        // Informações da viagem
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoChip(
              icon: Icons.route,
              label: widget.request.formattedDistance,
              color: DesignTokens.infoBlue,
            ),
            _buildInfoChip(
              icon: Icons.access_time,
              label: widget.request.formattedDuration,
              color: DesignTokens.warningOrange,
            ),
            _buildInfoChip(
              icon: Icons.attach_money,
              label: widget.request.formattedPrice,
              color: DesignTokens.successGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSm,
        vertical: DesignTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: DesignTokens.iconSm),
          const SizedBox(width: DesignTokens.space2xs),
          Text(
            label,
            style: DesignTokens.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Botão Recusar
        Expanded(
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onDecline,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.errorRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.spaceMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Recusar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),

        const SizedBox(width: DesignTokens.spaceMd),

        // Botão Aceitar
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.successGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.spaceMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Aceitar Viagem',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}
