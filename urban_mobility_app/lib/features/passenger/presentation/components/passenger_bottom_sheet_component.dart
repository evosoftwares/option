import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../providers/passenger_map_provider.dart';
import '../providers/address_history_provider.dart';
import '../../domain/models/address_history_item.dart';
import '../../../../shared/components/empty_state_component.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../transport/domain/models/location_data.dart';

/// Performance monitoring para debug builds
class _PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  
  static void startTimer(String name) {
    if (kDebugMode) {
      _timers[name] = Stopwatch()..start();
    }
  }
  
  static void endTimer(String name) {
    if (kDebugMode && _timers.containsKey(name)) {
      final elapsed = _timers[name]!.elapsedMilliseconds;
      if (elapsed > 16) { // Frame budget de 16ms
        debugPrint('⚠️ Performance: $name took ${elapsed}ms');
      }
      _timers.remove(name);
    }
  }
}

/// Widget do bottom sheet deslizável da tela do passageiro
class PassengerBottomSheetComponent extends ConsumerStatefulWidget {
  const PassengerBottomSheetComponent({
    super.key,
    required this.onDestinationSelected,
  });

  final void Function(Prediction) onDestinationSelected;

  @override
  ConsumerState<PassengerBottomSheetComponent> createState() => _PassengerBottomSheetComponentState();
}

class _PassengerBottomSheetComponentState extends ConsumerState<PassengerBottomSheetComponent>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _scrollController = DraggableScrollableController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _handleAnimationController;
  late Animation<double> _handleAnimation;
  
  bool _showAddressHistory = true;
  double _lastSnapPosition = _initialChildSize;

  // Estados do painel
  static const double _minChildSize = 0.15;
  static const double _initialChildSize = 0.25;
  static const double _maxChildSize = 0.85;

  @override
  void initState() {
    super.initState();
    
    // Configurar animação do handle
    _handleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _handleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _handleAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Listeners
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _expandBottomSheet();
      } else {
        // Se não tem foco e não tem texto, colapsa
        if (_searchController.text.trim().isEmpty) {
          _collapseBottomSheet();
        }
      }
    });
    
    _searchController.addListener(() {
      final hasText = _searchController.text.trim().isNotEmpty;
      
      // Atualiza a visibilidade do histórico
      if (_showAddressHistory == hasText) {
        setState(() {
          _showAddressHistory = !hasText;
        });
      }
      
      // Expande o bottom sheet quando há texto (mesmo sem foco)
      if (hasText) {
        _expandBottomSheet();
      }
      // Colapsa quando não há texto e não tem foco
      else if (!hasText && !_searchFocusNode.hasFocus) {
        _collapseBottomSheet();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _handleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      child: DraggableScrollableSheet(
      controller: _scrollController,
      initialChildSize: _initialChildSize,
      minChildSize: _minChildSize,
      maxChildSize: _maxChildSize,
      snap: true,
      snapSizes: const [0.15, 0.25, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: DesignTokens.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
            boxShadow: DesignTokens.shadowXl,
          ),
          child: Column(
            children: [
              RepaintBoundary(child: _buildFixedHeader()),
              Expanded(
                child: RepaintBoundary(child: _buildScrollableContent(scrollController)),
              ),
            ],
          ),
        );
      },
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Área draggable - handle e espaçamento
        RepaintBoundary(
          child: _OptimizedGestureDetector(
            onPanStart: (details) {
              _handleAnimationController.forward();
              // Feedback háptico leve ao iniciar o gesture
              HapticFeedback.lightImpact();
            },
            onPanUpdate: (details) {
              final currentSize = _scrollController.size;
              final screenHeight = MediaQuery.of(context).size.height;
              
              // Sensibilidade proporcional à altura da tela para movimento natural
              final sensitivity = 1.0 / screenHeight;
              final delta = -details.delta.dy * sensitivity;
              
              // Aplicar curva de resposta para movimento mais suave
              final responseCurve = delta > 0 
                  ? math.pow(delta.abs(), 0.8) * delta.sign 
                  : -math.pow(delta.abs(), 0.8);
              
              final newSize = (currentSize + responseCurve).clamp(_minChildSize, _maxChildSize);
              
              // Feedback háptico ao passar pelos pontos de snap
              _checkSnapFeedback(currentSize, newSize);
              
              if (_scrollController.isAttached) {
                _scrollController.jumpTo(newSize);
              }
            },
            onPanEnd: (details) {
              _handleAnimationController.reverse();
              
              // Snap inteligente baseado na velocidade e posição
              final currentSize = _scrollController.size;
              final velocity = details.velocity.pixelsPerSecond.dy;
              final screenHeight = MediaQuery.of(context).size.height;
              final velocityThreshold = screenHeight * 0.5; // 50% da altura da tela por segundo
              
              double targetSize;
              
              // Se a velocidade é alta, usar direção da velocidade
              if (velocity.abs() > velocityThreshold) {
                if (velocity > 0) {
                  // Movimento para baixo (fechar)
                  targetSize = currentSize > _initialChildSize ? _initialChildSize : _minChildSize;
                } else {
                  // Movimento para cima (abrir)
                  targetSize = currentSize < _initialChildSize ? _initialChildSize : _maxChildSize;
                }
              } else {
                // Snap baseado na posição atual
                if (currentSize < 0.2) {
                  targetSize = _minChildSize;
                } else if (currentSize < 0.55) {
                  targetSize = _initialChildSize;
                } else {
                  targetSize = _maxChildSize;
                }
              }
              
              if (_scrollController.isAttached) {
                _scrollController.animateTo(
                  targetSize,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spaceLg, 
                DesignTokens.spaceMd, 
                DesignTokens.spaceLg, 
                DesignTokens.spaceMd
              ),
              child: RepaintBoundary(child: _buildAnimatedHandle()),
            ),
          ),
        ),
        
        // Campo de busca - NÃO draggable
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignTokens.spaceLg, 
            0, 
            DesignTokens.spaceLg, 
            DesignTokens.spaceMd
          ),
          child: RepaintBoundary(child: _buildSearchBar()),
        ),
      ],
    );
  }


  Widget _buildScrollableContent(ScrollController scrollController) {
    _PerformanceMonitor.startTimer('buildScrollableContent');
    
    // Selectors ultra-granulares para máxima performance
    final error = ref.watch(passengerMapProvider.select((state) => state.error));
    final currentLocation = ref.watch(passengerMapProvider.select((state) => state.currentLocation));
    final isLoading = ref.watch(passengerMapProvider.select((state) => state.isLoading));

    final content = Semantics(
      label: 'Conteúdo de busca e histórico',
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(DesignTokens.spaceLg, 0, DesignTokens.spaceLg, DesignTokens.spaceLg),
        children: [
          if (error != null) 
            RepaintBoundary(
              key: ValueKey('error_$error'),
              child: _CachedErrorMessage(error: error),
            ),
          if (_showAddressHistory && !isLoading) 
            RepaintBoundary(
              key: ValueKey('location_${currentLocation?.hashCode}'),
              child: _CachedCurrentLocationInfo(currentLocation: currentLocation),
            ),
          if (_showAddressHistory) 
            const SizedBox(height: DesignTokens.spaceLg),
          if (_showAddressHistory) 
            RepaintBoundary(
              key: const ValueKey('address_history'),
              child: _CachedAddressHistory(
                onHistoryItemTap: _handleHistoryItemTap,
              ),
            ),
        ],
      ),
    );
    
    _PerformanceMonitor.endTimer('buildScrollableContent');
    return content;
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Semantics(
        label: 'Erro: $message',
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationInfo(LocationData? currentLocation) {
    if (currentLocation == null) {
      return const SizedBox.shrink();
    }

    final location = currentLocation;
    final displayAddress = location.fullAddress.isNotEmpty 
        ? location.fullAddress 
        : 'Endereço não disponível';

    return Semantics(
      label: 'Localização atual: $displayAddress',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 123, 255),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x20000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sua localização atual',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayAddress,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHandle() {
    return AnimatedBuilder(
      animation: _handleAnimation,
      builder: (context, child) {
        return Semantics(
          label: 'Arraste para ajustar o painel',
          hint: 'Toque e arraste para cima ou para baixo',
          child: Center(
            child: Container(
              width: 40 + (_handleAnimation.value * 20),
              height: 4,
              decoration: BoxDecoration(
                color: Color.lerp(
                  const Color(0xFFE2E8F0),
                  const Color(0xFF94A3B8),
                  _handleAnimation.value,
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: _handleAnimation.value > 0 ? [
                  const BoxShadow(
                    color: Color(0x19000000), // 0.1 opacity
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ] : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Semantics(
        label: 'Campo de busca de destino',
        child: GooglePlaceAutoCompleteTextField(
          textEditingController: _searchController,
          focusNode: _searchFocusNode,
          googleAPIKey: AppConstants.googleMapsApiKey,
          inputDecoration: const InputDecoration(
            hintText: 'Para onde você quer ir?',
            hintStyle: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 16,
              letterSpacing: -0.1,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xFF64748B),
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          ),
          debounceTime: 600,
          countries: const ['br'],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            widget.onDestinationSelected(prediction);
            _addToAddressHistory(prediction);
            
            // Limpar o campo e remover foco antes de colapsar
            _searchController.clear();
            _searchFocusNode.unfocus();
            
            // Pequeno delay para garantir que o campo foi limpo antes de colapsar
            Future.delayed(const Duration(milliseconds: 100), () {
              _collapseBottomSheet();
            });
          },
          itemClick: (Prediction prediction) {
            _searchController.text = prediction.description ?? '';
            _searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0),
            );
          },
          seperatedBuilder: const Divider(height: 1, color: Color(0xFFE5E7EB)),
          containerHorizontalPadding: 16,
          itemBuilder: (context, index, Prediction prediction) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCFD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x04000000),
                    blurRadius: 6,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Semantics(
                label: 'Sugestão: ${prediction.description}',
                button: true,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prediction.structuredFormatting?.mainText ?? 
                            prediction.description ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (prediction.structuredFormatting?.secondaryText != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                prediction.structuredFormatting!.secondaryText!,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddressHistory() {
    return RepaintBoundary(
      child: Consumer(
        builder: (context, ref, child) {
          final historyState = ref.watch(addressHistoryProvider);
          
          if (historyState.isLoading) {
            return Semantics(
              label: 'Carregando histórico de endereços',
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          if (historyState.error != null) {
            return Semantics(
              label: 'Erro no histórico: ${historyState.error}',
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        historyState.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: 'Botão tentar novamente',
                        button: true,
                        child: TextButton(
                          onPressed: () {
                            ref.read(addressHistoryProvider.notifier).refresh();
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (historyState.items.isEmpty) {
            return const EmptyStateComponent(
              title: 'Nenhum local recente',
              description: 'Seus destinos recentes aparecerão aqui para facilitar o acesso.',
              icon: Icons.history,
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            );
          }

          return Semantics(
            label: 'Lista de locais recentes',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Locais recentes',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (historyState.items.isNotEmpty)
                      Semantics(
                        label: 'Limpar histórico',
                        button: true,
                        child: TextButton(
                          onPressed: () {
                            ref.read(addressHistoryProvider.notifier).clearAll();
                          },
                          child: const Text(
                            'Limpar',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: historyState.items.length,
                  itemExtent: 72.0, // Altura fixa otimizada
                  itemBuilder: (context, index) {
                    return RepaintBoundary(
                      key: ValueKey(historyState.items[index].id),
                      child: _OptimizedHistoryItem(
                        item: historyState.items[index],
                        onTap: () => _handleHistoryItemTap(historyState.items[index]),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void _addToAddressHistory(Prediction prediction) {
    if (prediction.description != null) {
      ref.read(addressHistoryProvider.notifier).addToHistory(
        address: prediction.description!,
        shortName: prediction.structuredFormatting?.mainText,
        latitude: double.tryParse(prediction.lat ?? '0') ?? 0,
        longitude: double.tryParse(prediction.lng ?? '0') ?? 0,
      );
    }
  }

  void _checkSnapFeedback(double oldSize, double newSize) {
    const snapPoints = [_minChildSize, _initialChildSize, _maxChildSize];
    const tolerance = 0.02; // 2% de tolerância
    
    for (final snapPoint in snapPoints) {
      // Verifica se cruzou um ponto de snap
      final crossedSnap = (oldSize < snapPoint && newSize >= snapPoint) ||
                         (oldSize > snapPoint && newSize <= snapPoint);
      
      if (crossedSnap && (snapPoint - _lastSnapPosition).abs() > tolerance) {
        HapticFeedback.selectionClick();
        _lastSnapPosition = snapPoint;
        break;
      }
    }
  }

  void _expandBottomSheet() {
    if (_scrollController.isAttached) {
      _scrollController.animateTo(
        _maxChildSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    _handleAnimationController.forward();
  }

  void _collapseBottomSheet() {
    if (_scrollController.isAttached) {
      _scrollController.animateTo(
        _initialChildSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    _handleAnimationController.reverse();
  }

  void _handleHistoryItemTap(AddressHistoryItem item) {
    final prediction = Prediction(
      description: item.address,
      lat: item.latitude.toString(),
      lng: item.longitude.toString(),
      structuredFormatting: StructuredFormatting(
        mainText: item.shortName ?? item.address,
        secondaryText: item.shortName != null ? item.address : null,
      ),
    );
    
    widget.onDestinationSelected(prediction);
    
    ref.read(addressHistoryProvider.notifier).addToHistory(
      address: item.address,
      shortName: item.shortName,
      latitude: item.latitude,
      longitude: item.longitude,
    );
    
    // Limpar o campo e remover foco antes de colapsar
    _searchController.clear();
    _searchFocusNode.unfocus();
    
    // Pequeno delay para garantir que o estado foi atualizado
    Future.delayed(const Duration(milliseconds: 100), () {
      _collapseBottomSheet();
    });
  }
}

/// Widget otimizado para gesture detection com performance melhorada
class _OptimizedGestureDetector extends StatelessWidget {
  const _OptimizedGestureDetector({
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.child,
  });

  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

/// Widget otimizado para itens de histórico com cache e performance
class _OptimizedHistoryItem extends StatelessWidget {
  const _OptimizedHistoryItem({
    required this.item,
    required this.onTap,
  });

  final AddressHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Local recente: ${item.shortName ?? item.address}, usado ${item.usageCount} vezes',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.shortName ?? item.address,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.shortName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.address,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '${item.usageCount}x',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget cached para mensagens de erro com performance otimizada
class _CachedErrorMessage extends StatelessWidget {
  const _CachedErrorMessage({required this.error});
  
  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Semantics(
        label: 'Erro: $error',
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget cached para informações de localização atual
class _CachedCurrentLocationInfo extends StatelessWidget {
  const _CachedCurrentLocationInfo({required this.currentLocation});
  
  final LocationData? currentLocation;

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const SizedBox.shrink();
    }

    final location = currentLocation!;
    final displayAddress = location.fullAddress.isNotEmpty 
        ? location.fullAddress 
        : 'Endereço não disponível';

    return Semantics(
      label: 'Localização atual: $displayAddress',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 123, 255),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x20000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sua localização atual',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayAddress,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget cached para histórico de endereços com performance otimizada
class _CachedAddressHistory extends ConsumerWidget {
  const _CachedAddressHistory({
    required this.onHistoryItemTap,
  });
  
  final void Function(AddressHistoryItem) onHistoryItemTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _PerformanceMonitor.startTimer('buildAddressHistory');
    
    // Selector granular apenas para os itens do histórico
    final historyItems = ref.watch(addressHistoryProvider.select((state) => state.items));
    final isLoading = ref.watch(addressHistoryProvider.select((state) => state.isLoading));
    
    Widget content;
    
    if (isLoading) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (historyItems.isEmpty) {
       content = const EmptyStateComponent(
         icon: Icons.history,
         title: 'Nenhum histórico ainda',
         description: 'Seus destinos recentes aparecerão aqui',
       );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Locais recentes',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historyItems.length,
            itemExtent: 72.0,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                 key: ValueKey(historyItems[index].id),
                 child: _OptimizedHistoryItem(
                   item: historyItems[index],
                   onTap: () => onHistoryItemTap(historyItems[index]),
                 ),
               );
            },
          ),
        ],
      );
    }
    
    _PerformanceMonitor.endTimer('buildAddressHistory');
    
    return Semantics(
      label: 'Histórico de endereços',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        ),
        child: content,
      ),
    );
  }
}