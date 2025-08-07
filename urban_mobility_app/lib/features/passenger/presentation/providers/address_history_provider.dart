import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/address_history_service.dart';
import '../../domain/models/address_history_item.dart';

/// Estado do histórico de endereços
class AddressHistoryState {
  const AddressHistoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  final List<AddressHistoryItem> items;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  AddressHistoryState copyWith({
    List<AddressHistoryItem>? items,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return AddressHistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Provider para o serviço de histórico de endereços
final addressHistoryServiceProvider = Provider<AddressHistoryService>((ref) {
  return AddressHistoryService();
});

/// Notifier para gerenciar o histórico de endereços com cache e otimizações
class AddressHistoryNotifier extends StateNotifier<AddressHistoryState> {
  AddressHistoryNotifier(this._service) : super(const AddressHistoryState()) {
    _initialize();
  }

  final AddressHistoryService _service;
  StreamSubscription<List<AddressHistoryItem>>? _subscription;
  Timer? _debounceTimer;
  
  static const Duration _cacheDuration = Duration(minutes: 5);
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  /// Inicializa o provider e configura listeners
  void _initialize() {
    _loadHistory();
  }

  /// Carrega o histórico com cache inteligente
  void _loadHistory() {
    // Verifica se o cache ainda é válido
    if (_isCacheValid()) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    _subscription?.cancel();
    _subscription = _service.getAddressHistory().listen(
      (items) {
        state = state.copyWith(
          items: items,
          isLoading: false,
          error: null,
          lastUpdated: DateTime.now(),
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao carregar histórico: $error',
        );
      },
    );
  }

  /// Verifica se o cache ainda é válido
  bool _isCacheValid() {
    final lastUpdated = state.lastUpdated;
    if (lastUpdated == null) return false;
    
    return DateTime.now().difference(lastUpdated) < _cacheDuration;
  }

  /// Adiciona um item ao histórico com debouncing
  void addToHistory({
    required String address,
    required double latitude,
    required double longitude,
    String? shortName,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _service.addToHistory(
        address: address,
        latitude: latitude,
        longitude: longitude,
        shortName: shortName,
      );
    });
  }

  /// Busca no histórico local (sem consulta ao Firestore)
  List<AddressHistoryItem> searchLocal(String query) {
    if (query.isEmpty) return state.items;
    
    final queryLower = query.toLowerCase();
    return state.items.where((item) {
      return item.address.toLowerCase().contains(queryLower) ||
             (item.shortName?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  /// Remove um item do histórico
  Future<void> removeItem(String itemId) async {
    try {
      await _service.removeFromHistory(itemId);
      // A remoção será refletida automaticamente pelo stream
    } catch (error) {
      state = state.copyWith(error: 'Erro ao remover item: $error');
    }
  }

  /// Limpa todo o histórico
  Future<void> clearAll() async {
    try {
      await _service.clearHistory();
      // A limpeza será refletida automaticamente pelo stream
    } catch (error) {
      state = state.copyWith(error: 'Erro ao limpar histórico: $error');
    }
  }

  /// Força a atualização do cache
  void refresh() {
    state = state.copyWith(lastUpdated: null);
    _loadHistory();
  }

  /// Limpa erros
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider principal para o histórico de endereços
final addressHistoryProvider = StateNotifierProvider<AddressHistoryNotifier, AddressHistoryState>((ref) {
  return AddressHistoryNotifier(ref.read(addressHistoryServiceProvider));
});

/// Provider para itens filtrados (útil para busca)
final filteredAddressHistoryProvider = Provider.family<List<AddressHistoryItem>, String>((ref, query) {
  final notifier = ref.read(addressHistoryProvider.notifier);
  return notifier.searchLocal(query);
});