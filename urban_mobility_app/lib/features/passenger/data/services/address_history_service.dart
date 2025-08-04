import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/address_history_item.dart';

/// Serviço para gerenciar o histórico de endereços do usuário no Firestore
class AddressHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'address_history';
  static const int _maxHistoryItems = 10;

  /// Obtém a referência da coleção de histórico do usuário atual
  CollectionReference<AddressHistoryItem>? _getUserHistoryCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection(_collection)
        .withConverter<AddressHistoryItem>(
          fromFirestore: AddressHistoryItem.fromFirestore,
          toFirestore: (item, _) => item.toFirestore(),
        );
  }

  /// Obtém o histórico de endereços do usuário ordenado por último uso
  Stream<List<AddressHistoryItem>> getAddressHistory() {
    final collection = _getUserHistoryCollection();
    if (collection == null) {
      return Stream.value([]);
    }

    return collection
        .orderBy('lastUsed', descending: true)
        .limit(_maxHistoryItems)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Adiciona ou atualiza um endereço no histórico
  Future<void> addToHistory({
    required String address,
    required double latitude,
    required double longitude,
    String? shortName,
  }) async {
    final collection = _getUserHistoryCollection();
    if (collection == null) return;

    try {
      // Verifica se já existe um endereço similar (mesmo lat/lng com tolerância)
      final existingQuery = await collection
          .where('latitude', isGreaterThan: latitude - 0.001)
          .where('latitude', isLessThan: latitude + 0.001)
          .get();

      AddressHistoryItem? existingItem;
      for (final doc in existingQuery.docs) {
        final item = doc.data();
        final latDiff = (item.latitude - latitude).abs();
        final lngDiff = (item.longitude - longitude).abs();
        
        // Se a diferença for menor que ~100m, considera o mesmo local
        if (latDiff < 0.001 && lngDiff < 0.001) {
          existingItem = item;
          break;
        }
      }

      if (existingItem != null) {
        // Atualiza o item existente
        await collection.doc(existingItem.id).update({
          'address': address,
          'shortName': shortName,
          'lastUsed': Timestamp.now(),
          'usageCount': FieldValue.increment(1),
        });
      } else {
        // Cria um novo item
        final newItem = AddressHistoryItem(
          id: '', // Será gerado pelo Firestore
          address: address,
          shortName: shortName,
          latitude: latitude,
          longitude: longitude,
          lastUsed: DateTime.now(),
          usageCount: 1,
        );

        await collection.add(newItem);

        // Remove itens antigos se exceder o limite
        await _cleanupOldItems(collection);
      }
    } catch (e) {
      print('Erro ao adicionar endereço ao histórico: $e');
      rethrow;
    }
  }

  /// Remove itens antigos do histórico mantendo apenas os mais recentes
  Future<void> _cleanupOldItems(
    CollectionReference<AddressHistoryItem> collection,
  ) async {
    try {
      final snapshot = await collection
          .orderBy('lastUsed', descending: true)
          .get();

      if (snapshot.docs.length > _maxHistoryItems) {
        final itemsToDelete = snapshot.docs.skip(_maxHistoryItems);
        
        final batch = _firestore.batch();
        for (final doc in itemsToDelete) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
      }
    } catch (e) {
      print('Erro ao limpar histórico antigo: $e');
    }
  }

  /// Remove um item específico do histórico
  Future<void> removeFromHistory(String itemId) async {
    final collection = _getUserHistoryCollection();
    if (collection == null) return;

    try {
      await collection.doc(itemId).delete();
    } catch (e) {
      print('Erro ao remover item do histórico: $e');
      rethrow;
    }
  }

  /// Limpa todo o histórico do usuário
  Future<void> clearHistory() async {
    final collection = _getUserHistoryCollection();
    if (collection == null) return;

    try {
      final snapshot = await collection.get();
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Erro ao limpar histórico: $e');
      rethrow;
    }
  }

  /// Busca no histórico por texto
  Future<List<AddressHistoryItem>> searchHistory(String query) async {
    final collection = _getUserHistoryCollection();
    if (collection == null) return [];

    try {
      final snapshot = await collection
          .orderBy('lastUsed', descending: true)
          .get();

      final queryLower = query.toLowerCase();
      return snapshot.docs
          .map((doc) => doc.data())
          .where((item) =>
              item.address.toLowerCase().contains(queryLower) ||
              (item.shortName?.toLowerCase().contains(queryLower) ?? false))
          .toList();
    } catch (e) {
      print('Erro ao buscar no histórico: $e');
      return [];
    }
  }
}