import 'package:flutter/material.dart';

class BottomPickupPanelComponent extends StatelessWidget {

  const BottomPickupPanelComponent({
    super.key,
    required this.currentAddress,
    required this.fullAddress,
    required this.isLoadingAddress,
    required this.isMapMoving,
    required this.onSearchPressed,
    required this.onConfirmPressed,
  });
  final String currentAddress;
  final String fullAddress;
  final bool isLoadingAddress;
  final bool isMapMoving;
  final VoidCallback onSearchPressed;
  final VoidCallback onConfirmPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20.0,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle visual do painel
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Título
          const Text(
            'Confirme seu local de embarque',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Subtítulo dinâmico
          Text(
            isMapMoving 
              ? 'Solte para selecionar este local'
              : 'Mova o pino no mapa para ajustar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, 
              color: isMapMoving ? Colors.blue[700] : Colors.grey[600],
              fontWeight: isMapMoving ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 24),

          // Campo de endereço clicável
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSearchPressed,
              borderRadius: BorderRadius.circular(8),
              child: _buildAddressDisplay(),
            ),
          ),
          const SizedBox(height: 24),

          // Botão de confirmação
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoadingAddress ? null : onConfirmPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: isLoadingAddress ? 0 : 2,
              ),
              child: isLoadingAddress
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Confirmar embarque',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDisplay() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isLoadingAddress 
            ? Colors.blue.withOpacity(0.5) 
            : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Ícone
          Icon(
            isLoadingAddress ? Icons.location_searching : Icons.location_on,
            color: isLoadingAddress ? Colors.blue : Colors.grey[800],
            size: 24,
          ),
          const SizedBox(width: 12),
          
          // Conteúdo do endereço
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Endereço principal
                if (isLoadingAddress)
                  _buildLoadingShimmer()
                else
                  Text(
                    currentAddress,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                
                // Endereço complementar
                Text(
                  isLoadingAddress 
                    ? 'Obtendo localização...'
                    : fullAddress.isNotEmpty 
                      ? fullAddress
                      : 'Toque para buscar endereço',
                  style: TextStyle(
                    fontSize: 14,
                    color: isLoadingAddress 
                      ? Colors.grey[400] 
                      : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Ícone de ação
          Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: const LinearProgressIndicator(
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
      ),
    );
  }
}