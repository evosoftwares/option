import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/driver_profile.dart';
import '../../domain/models/driver_work_config.dart';
import '../../domain/models/driver_status.dart' hide DriverLocation;
import '../../domain/models/ride_request.dart' hide VehicleCategory;
import '../../domain/models/active_ride.dart';
import '../../domain/models/driver_documents.dart';
import '../../domain/models/vehicle_info.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_remote_datasource.dart';

/// Implementação do datasource remoto do motorista usando Firebase Firestore
/// Segue as regras de negócio definidas no documento regrasdenegocio.md
class DriverRemoteDatasourceFirestore implements DriverRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Coleções Firestore conforme regras de negócio
  static const String _driversCollection = 'drivers';
  static const String _ridesCollection = 'rides';
  static const String _rideRequestsCollection = 'ride_requests';
  static const String _statusHistorySubcollection = 'status_history';
  static const String _earningsSubcollection = 'earnings';
  static const String _ratingsSubcollection = 'ratings';
  static const String _notificationsSubcollection = 'notifications';

  // ========== Gestão de Perfil ==========
  
  @override
  Future<DriverProfile?> getDriverProfile(String driverId) async {
    try {
      final doc = await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return DriverProfile.fromFirestore(data, doc.id);
    } catch (e) {
      throw Exception('Erro ao buscar perfil do motorista: $e');
    }
  }

  @override
  Future<void> updateDriverProfile(DriverProfile profile) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(profile.id)
          .set(profile.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erro ao atualizar perfil do motorista: $e');
    }
  }

  @override
  Future<String> createDriverProfile(DriverProfile profile) async {
    try {
      final docRef = await _firestore
          .collection(_driversCollection)
          .add(profile.toFirestore());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar perfil do motorista: $e');
    }
  }

  @override
  Future<void> updatePersonalInfo(String driverId, PersonalInfo personalInfo) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'personalInfo': personalInfo.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Regra de negócio: alteração em dados críticos requer nova aprovação
        'verificationStatus': 'pending',
      });
    } catch (e) {
      throw Exception('Erro ao atualizar informações pessoais: $e');
    }
  }

  @override
  Future<void> updateVehicleInfo(String driverId, VehicleInfo vehicleInfo) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'vehicleInfo': vehicleInfo.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Regra de negócio: alteração em dados críticos requer nova aprovação
        'verificationStatus': 'pending',
      });
    } catch (e) {
      throw Exception('Erro ao atualizar informações do veículo: $e');
    }
  }

  @override
  Future<void> updateDriverDocuments(String driverId, DriverDocuments documents) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'documents': documents.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Regra de negócio: alteração em documentos requer nova aprovação
        'verificationStatus': 'pending',
      });
    } catch (e) {
      throw Exception('Erro ao atualizar documentos: $e');
    }
  }

  @override
  Future<String> uploadDocumentPhoto(String driverId, String documentType, String filePath) async {
    // TODO: Implementar upload para Firebase Storage
    // Por enquanto retorna URL mock
    return 'https://storage.googleapis.com/option-app/$driverId/$documentType.jpg';
  }

  @override
  Future<void> submitDocumentsForVerification(String driverId) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'verificationStatus': 'pending',
        'submittedForVerificationAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao submeter documentos para verificação: $e');
    }
  }

  // ========== Configuração de Trabalho ==========
  
  @override
  Future<DriverWorkConfig?> getWorkConfig(String driverId) async {
    try {
      final doc = await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      if (data['workConfig'] == null) return null;
      
      return DriverWorkConfig.fromFirestore(data['workConfig']);
    } catch (e) {
      throw Exception('Erro ao buscar configuração de trabalho: $e');
    }
  }

  @override
  Future<void> updateWorkConfig(String driverId, DriverWorkConfig config) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'workConfig': config.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar configuração de trabalho: $e');
    }
  }

  @override
  Future<void> updatePricingConfig(String driverId, PricingConfig pricing) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'workConfig.pricingConfig': pricing.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar configuração de preços: $e');
    }
  }

  @override
  Future<void> updateServiceFees(String driverId, ServiceFees fees) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'workConfig.serviceFees': fees.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar taxas de serviço: $e');
    }
  }

  @override
  Future<void> addWorkingArea(String driverId, WorkingArea area) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'workConfig.workingAreas': FieldValue.arrayUnion([area.toFirestore()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar área de trabalho: $e');
    }
  }

  @override
  Future<void> removeWorkingArea(String driverId, String areaId) async {
    try {
      // Primeiro busca a área para removê-la
      final doc = await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        final workConfig = data['workConfig'] as Map<String, dynamic>?;
        final areas = workConfig?['workingAreas'] as List<dynamic>? ?? [];
        
        // Remove a área com o ID especificado
        final updatedAreas = areas.where((area) => area['id'] != areaId).toList();
        
        await _firestore
            .collection(_driversCollection)
            .doc(driverId)
            .update({
          'workConfig.workingAreas': updatedAreas,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Erro ao remover área de trabalho: $e');
    }
  }

  // ========== Gestão de Status ==========
  
  @override
  Future<DriverStatus> getDriverStatus(String driverId) async {
    try {
      final doc = await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .get();
      
      if (!doc.exists) return DriverStatus.offline;
      
      final data = doc.data()!;
      final statusString = data['status'] as String? ?? 'offline';
      
      switch (statusString) {
        case 'online':
          return DriverStatus.online;
        case 'busy':
          return DriverStatus.busy;
        case 'paused':
          return DriverStatus.paused;
        default:
          return DriverStatus.offline;
      }
    } catch (e) {
      throw Exception('Erro ao buscar status do motorista: $e');
    }
  }

  @override
  Future<void> updateDriverStatus(String driverId, DriverStatus status) async {
    try {
      String statusString;
      switch (status) {
        case DriverStatus.online:
          statusString = 'online';
          break;
        case DriverStatus.busy:
          statusString = 'busy';
          break;
        case DriverStatus.paused:
          statusString = 'paused';
          break;
        case DriverStatus.offline:
          statusString = 'offline';
          break;
      }

      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'status': statusString,
        'lastStatusUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar status do motorista: $e');
    }
  }

  @override
  Future<void> goOnline(String driverId, DriverLocation location) async {
    try {
      final batch = _firestore.batch();
      
      // Atualizar status do motorista
      final driverRef = _firestore.collection(_driversCollection).doc(driverId);
      batch.update(driverRef, {
        'status': 'online',
        'location': location.toFirestore(),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
        'lastStatusUpdate': FieldValue.serverTimestamp(),
      });
      
      // Registrar no histórico de status
      final statusHistoryRef = driverRef
          .collection(_statusHistorySubcollection)
          .doc();
      batch.set(statusHistoryRef, {
        'status': 'online',
        'timestamp': FieldValue.serverTimestamp(),
        'location': location.toFirestore(),
      });
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao ficar online: $e');
    }
  }

  @override
  Future<void> goOffline(String driverId) async {
    try {
      final batch = _firestore.batch();
      
      // Atualizar status do motorista
      final driverRef = _firestore.collection(_driversCollection).doc(driverId);
      batch.update(driverRef, {
        'status': 'offline',
        'lastStatusUpdate': FieldValue.serverTimestamp(),
      });
      
      // Registrar no histórico de status
      final statusHistoryRef = driverRef
          .collection(_statusHistorySubcollection)
          .doc();
      batch.set(statusHistoryRef, {
        'status': 'offline',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao ficar offline: $e');
    }
  }

  @override
  Future<void> pauseActivity(String driverId, String reason) async {
    try {
      final batch = _firestore.batch();
      
      // Atualizar status do motorista
      final driverRef = _firestore.collection(_driversCollection).doc(driverId);
      batch.update(driverRef, {
        'status': 'paused',
        'pauseReason': reason,
        'lastStatusUpdate': FieldValue.serverTimestamp(),
      });
      
      // Registrar no histórico de status
      final statusHistoryRef = driverRef
          .collection(_statusHistorySubcollection)
          .doc();
      batch.set(statusHistoryRef, {
        'status': 'paused',
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao pausar atividade: $e');
    }
  }

  @override
  Future<void> resumeActivity(String driverId) async {
    try {
      await updateDriverStatus(driverId, DriverStatus.online);
    } catch (e) {
      throw Exception('Erro ao retomar atividade: $e');
    }
  }

  @override
  Future<void> updateLocation(String driverId, DriverLocation location) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'location': location.toFirestore(),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar localização: $e');
    }
  }

  @override
  Future<List<DriverStatusHistory>> getStatusHistory(String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .collection(_statusHistorySubcollection)
          .orderBy('timestamp', descending: true);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }
      
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => DriverStatusHistory.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico de status: $e');
    }
  }

  // ========== Solicitações de Viagem ==========
  
  @override
  Stream<List<RideRequest>> getPendingRideRequests(String driverId) {
    try {
      // Implementa o algoritmo de matching conforme regras de negócio
      return _firestore
          .collection(_rideRequestsCollection)
          .where('status', isEqualTo: 'pending')
          .where('assignedDriverId', isNull: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final requests = <RideRequest>[];
        
        for (final doc in snapshot.docs) {
          final request = RideRequest.fromFirestore(doc.data(), doc.id);
          
          // Verificar se o motorista atende aos critérios da viagem
          if (await _driverMatchesRequest(driverId, request)) {
            requests.add(request);
          }
        }
        
        // Ordenar por distância (mais próximo primeiro)
        requests.sort((a, b) => a.distanceToDriver.compareTo(b.distanceToDriver));
        
        // Retornar apenas os 10 primeiros conforme regra de negócio
        return requests.take(10).toList();
      });
    } catch (e) {
      throw Exception('Erro ao buscar solicitações de viagem: $e');
    }
  }

  /// Verifica se o motorista atende aos critérios da solicitação
  /// Implementa as regras de matching da seção 5.1 do documento de negócio
  Future<bool> _driverMatchesRequest(String driverId, RideRequest request) async {
    try {
      final driverDoc = await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .get();
      
      if (!driverDoc.exists) return false;
      
      final driverData = driverDoc.data()!;
      final workConfig = driverData['workConfig'] as Map<String, dynamic>?;
      
      if (workConfig == null) return false;
      
      // Verificar zonas de exclusão (regra de negócio 5.1)
      final excludedNeighborhoods = workConfig['excludedNeighborhoods'] as List<dynamic>? ?? [];
      
      if (excludedNeighborhoods.contains(request.pickupLocation.neighborhood) ||
          excludedNeighborhoods.contains(request.destination.neighborhood)) {
        return false;
      }
      
      // Verificar categoria do veículo
      final vehicleInfo = driverData['vehicleInfo'] as Map<String, dynamic>?;
      if (vehicleInfo?['category'] != request.vehicleCategory.toString()) {
        return false;
      }
      
      // Para transporte de passageiros, verificar preferências específicas
      if (request.vehicleCategory.toString() == 'carroComum' || 
          request.vehicleCategory.toString() == 'carro7Lugares') {
        
        final serviceFees = workConfig['serviceFees'] as Map<String, dynamic>?;
        
        // Verificar se aceita pets
        if (request.needsPetTransport && 
            !(serviceFees?['petTransportService']?['isActive'] ?? false)) {
          return false;
        }
        
        // Verificar se aceita acesso a condomínio
        if (request.needsCondominiumAccess && 
            !(serviceFees?['condominiumAccessService']?['isActive'] ?? false)) {
          return false;
        }
        
        // Verificar se aceita paradas
        if (request.numberOfStops > 0 && 
            !(serviceFees?['stopService']?['isActive'] ?? false)) {
          return false;
        }
        
        // Verificar se aceita uso do porta-malas
        if (request.needsTrunkSpace && 
            !(serviceFees?['trunkService']?['isActive'] ?? false)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ActiveRide> acceptRideRequest(String driverId, String requestId) async {
    try {
      // Transação atômica para evitar concorrência (regra de negócio 5.3)
      return await _firestore.runTransaction((transaction) async {
        final requestRef = _firestore.collection(_rideRequestsCollection).doc(requestId);
        final driverRef = _firestore.collection(_driversCollection).doc(driverId);
        
        final requestDoc = await transaction.get(requestRef);
        final driverDoc = await transaction.get(driverRef);
        
        if (!requestDoc.exists || !driverDoc.exists) {
          throw Exception('Solicitação ou motorista não encontrado');
        }
        
        final requestData = requestDoc.data()!;
        
        // Verificar se a solicitação ainda está disponível
        if (requestData['status'] != 'pending' || requestData['assignedDriverId'] != null) {
          throw Exception('Solicitação não está mais disponível');
        }
        
        // Verificar se o motorista ainda está disponível
        final driverData = driverDoc.data()!;
        if (driverData['status'] != 'online') {
          throw Exception('Motorista não está mais disponível');
        }
        
        // Atualizar status da solicitação
        transaction.update(requestRef, {
          'status': 'accepted',
          'assignedDriverId': driverId,
          'acceptedAt': FieldValue.serverTimestamp(),
        });
        
        // Atualizar status do motorista para "busy"
        transaction.update(driverRef, {
          'status': 'busy',
          'currentRideId': requestId,
          'lastStatusUpdate': FieldValue.serverTimestamp(),
        });
        
        // Criar viagem ativa
        final rideRef = _firestore.collection(_ridesCollection).doc();
        final activeRide = ActiveRide.fromRideRequest(
          RideRequest.fromFirestore(requestData, requestId),
          driverId,
          rideRef.id,
        );
        
        transaction.set(rideRef, activeRide.toFirestore());
        
        return activeRide;
      });
    } catch (e) {
      throw Exception('Erro ao aceitar solicitação de viagem: $e');
    }
  }

  @override
  Future<void> rejectRideRequest(String driverId, String requestId, String reason) async {
    try {
      // Registrar rejeição para evitar mostrar novamente para este motorista
      await _firestore
          .collection(_rideRequestsCollection)
          .doc(requestId)
          .update({
        'rejectedBy': FieldValue.arrayUnion([{
          'driverId': driverId,
          'reason': reason,
          'rejectedAt': FieldValue.serverTimestamp(),
        }]),
      });
    } catch (e) {
      throw Exception('Erro ao rejeitar solicitação de viagem: $e');
    }
  }

  @override
  Future<RideRequest?> getRideRequestDetails(String requestId) async {
    try {
      final doc = await _firestore
          .collection(_rideRequestsCollection)
          .doc(requestId)
          .get();
      
      if (!doc.exists) return null;
      
      return RideRequest.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Erro ao buscar detalhes da solicitação: $e');
    }
  }

  // ========== Viagens Ativas ==========
  
  @override
  Future<ActiveRide?> getCurrentActiveRide(String driverId) async {
    try {
      final snapshot = await _firestore
          .collection(_ridesCollection)
          .where('driverId', isEqualTo: driverId)
          .where('status', whereIn: ['accepted', 'driverEnRoute', 'arrived', 'inProgress'])
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      final doc = snapshot.docs.first;
      return ActiveRide.fromFirestore(doc.data(), doc.id);
    } catch (e) {
      throw Exception('Erro ao buscar viagem ativa: $e');
    }
  }

  @override
  Future<void> updateActiveRideStatus(String rideId, ActiveRideStatus status) async {
    try {
      String statusString;
      switch (status) {
        case ActiveRideStatus.accepted:
          statusString = 'accepted';
          break;
        case ActiveRideStatus.driverEnRoute:
          statusString = 'driverEnRoute';
          break;
        case ActiveRideStatus.arrived:
          statusString = 'arrived';
          break;
        case ActiveRideStatus.inProgress:
          statusString = 'inProgress';
          break;
        case ActiveRideStatus.completed:
          statusString = 'completed';
          break;
        case ActiveRideStatus.cancelled:
          statusString = 'cancelled';
          break;
      }

      await _firestore
          .collection(_ridesCollection)
          .doc(rideId)
          .update({
        'status': statusString,
        'lastStatusUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar status da viagem: $e');
    }
  }

  @override
  Future<void> markArrivedAtPickup(String rideId) async {
    try {
      await _firestore
          .collection(_ridesCollection)
          .doc(rideId)
          .update({
        'status': 'arrived',
        'arrivedAtPickupAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao marcar chegada no local de embarque: $e');
    }
  }

  @override
  Future<void> markPassengerPickedUp(String rideId) async {
    try {
      await _firestore
          .collection(_ridesCollection)
          .doc(rideId)
          .update({
        'status': 'inProgress',
        'pickedUpAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao marcar passageiro embarcado: $e');
    }
  }

  @override
  Future<void> markArrivedAtDestination(String rideId) async {
    try {
      await _firestore
          .collection(_ridesCollection)
          .doc(rideId)
          .update({
        'arrivedAtDestinationAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao marcar chegada no destino: $e');
    }
  }

  @override
  Future<void> completeRide(String rideId, {
    required double finalPrice,
    double? actualDistance,
    int? actualDuration,
    int? waitingTime,
    String? notes,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Atualizar viagem
      final rideRef = _firestore.collection(_ridesCollection).doc(rideId);
      batch.update(rideRef, {
        'status': 'completed',
        'finalPrice': finalPrice,
        'actualDistance': actualDistance,
        'actualDuration': actualDuration,
        'waitingTime': waitingTime,
        'notes': notes,
        'completedAt': FieldValue.serverTimestamp(),
      });
      
      // Buscar dados da viagem para atualizar status do motorista
      final rideDoc = await rideRef.get();
      if (rideDoc.exists) {
        final rideData = rideDoc.data()!;
        final driverId = rideData['driverId'] as String;
        
        // Atualizar status do motorista para online
        final driverRef = _firestore.collection(_driversCollection).doc(driverId);
        batch.update(driverRef, {
          'status': 'online',
          'currentRideId': FieldValue.delete(),
          'lastStatusUpdate': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao completar viagem: $e');
    }
  }

  @override
  Future<void> cancelRide(String rideId, String reason) async {
    try {
      final batch = _firestore.batch();
      
      // Atualizar viagem
      final rideRef = _firestore.collection(_ridesCollection).doc(rideId);
      batch.update(rideRef, {
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      
      // Buscar dados da viagem para atualizar status do motorista
      final rideDoc = await rideRef.get();
      if (rideDoc.exists) {
        final rideData = rideDoc.data()!;
        final driverId = rideData['driverId'] as String;
        
        // Atualizar status do motorista para online
        final driverRef = _firestore.collection(_driversCollection).doc(driverId);
        batch.update(driverRef, {
          'status': 'online',
          'currentRideId': FieldValue.delete(),
          'lastStatusUpdate': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao cancelar viagem: $e');
    }
  }

  @override
  Future<void> addExtraStop(String rideId, RideLocation stop) async {
    try {
      await _firestore
          .collection(_ridesCollection)
          .doc(rideId)
          .update({
        'extraStops': FieldValue.arrayUnion([stop.toFirestore()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar parada extra: $e');
    }
  }

  @override
  Future<void> updateRideRoute(String rideId, RideRoute route) async {
    try {
      await _firestore
          .collection(_ridesCollection)
          .doc(rideId)
          .update({
        'route': route.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar rota da viagem: $e');
    }
  }

  // ========== Histórico e Relatórios ==========
  
  @override
  Future<List<ActiveRide>> getRideHistory(String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection(_ridesCollection)
          .where('driverId', isEqualTo: driverId)
          .where('status', whereIn: ['completed', 'cancelled'])
          .orderBy('completedAt', descending: true);

      if (startDate != null) {
        query = query.where('completedAt', isGreaterThanOrEqualTo: startDate);
      }
      
      if (endDate != null) {
        query = query.where('completedAt', isLessThanOrEqualTo: endDate);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => ActiveRide.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico de viagens: $e');
    }
  }

  @override
  Future<DriverStatistics> getDriverStatistics(String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Implementar cálculo de estatísticas baseado no histórico de viagens
      final rides = await getRideHistory(
        driverId,
        startDate: startDate,
        endDate: endDate,
      );
      
      final completedRides = rides.where((r) => r.status == ActiveRideStatus.completed).toList();
      final cancelledRides = rides.where((r) => r.status == ActiveRideStatus.cancelled).toList();
      
      final totalEarnings = completedRides.fold<double>(
        0.0,
        (sum, ride) => sum + (ride.finalPrice ?? 0.0),
      );
      
      final totalDistance = completedRides.fold<double>(
        0.0,
        (sum, ride) => sum + (ride.actualDistance ?? ride.estimatedDistance),
      );
      
      final totalDuration = completedRides.fold<int>(
        0,
        (sum, ride) => sum + (ride.actualDuration ?? ride.estimatedDuration),
      );
      
      return DriverStatistics(
        totalRides: completedRides.length,
        completedRides: completedRides.length,
        cancelledRides: cancelledRides.length,
        totalEarnings: totalEarnings,
        totalDistance: totalDistance,
        totalDuration: totalDuration,
        averageRating: 4.5, // TODO: Calcular baseado nas avaliações
        period: DateRange(startDate, endDate),
      );
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas do motorista: $e');
    }
  }

  @override
  Future<DriverEarnings> getDriverEarnings(String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final rides = await getRideHistory(
        driverId,
        startDate: startDate,
        endDate: endDate,
      );
      
      final completedRides = rides.where((r) => r.status == ActiveRideStatus.completed).toList();
      
      final grossEarnings = completedRides.fold<double>(
        0.0,
        (sum, ride) => sum + (ride.finalPrice ?? 0.0),
      );
      
      // Assumindo comissão de 20% (deve vir das configurações globais)
      const commissionRate = 0.20;
      final commission = grossEarnings * commissionRate;
      final netEarnings = grossEarnings - commission;
      
      return DriverEarnings(
        grossEarnings: grossEarnings,
        commission: commission,
        netEarnings: netEarnings,
        totalRides: completedRides.length,
        period: DateRange(startDate, endDate),
      );
    } catch (e) {
      throw Exception('Erro ao buscar ganhos do motorista: $e');
    }
  }

  @override
  Future<List<DriverRating>> getDriverRatings(String driverId, {
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .collection(_ratingsSubcollection)
          .orderBy('createdAt', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => DriverRating.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar avaliações do motorista: $e');
    }
  }

  // ========== Notificações ==========
  
  @override
  Future<List<DriverNotification>> getNotifications(String driverId, {
    bool? unreadOnly,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .collection(_notificationsSubcollection)
          .orderBy('createdAt', descending: true);

      if (unreadOnly == true) {
        query = query.where('isRead', isEqualTo: false);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => DriverNotification.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar notificações: $e');
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      // Buscar a notificação para obter o driverId
      final notificationQuery = await _firestore
          .collectionGroup(_notificationsSubcollection)
          .where(FieldPath.documentId, isEqualTo: notificationId)
          .limit(1)
          .get();
      
      if (notificationQuery.docs.isNotEmpty) {
        final doc = notificationQuery.docs.first;
        await doc.reference.update({
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Erro ao marcar notificação como lida: $e');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String driverId) async {
    try {
      final batch = _firestore.batch();
      
      final snapshot = await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .collection(_notificationsSubcollection)
          .where('isRead', isEqualTo: false)
          .get();
      
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao marcar todas as notificações como lidas: $e');
    }
  }

  // ========== Configurações ==========
  
  @override
  Future<DriverAppSettings> getAppSettings(String driverId) async {
    try {
      final doc = await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Motorista não encontrado');
      }
      
      final data = doc.data()!;
      final settingsData = data['appSettings'] as Map<String, dynamic>?;
      
      if (settingsData == null) {
        // Retornar configurações padrão
        return DriverAppSettings.defaultSettings();
      }
      
      return DriverAppSettings.fromFirestore(settingsData);
    } catch (e) {
      throw Exception('Erro ao buscar configurações do app: $e');
    }
  }

  @override
  Future<void> updateAppSettings(String driverId, DriverAppSettings settings) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'appSettings': settings.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar configurações do app: $e');
    }
  }

  @override
  Future<NotificationSettings> getNotificationSettings(String driverId) async {
    try {
      final doc = await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Motorista não encontrado');
      }
      
      final data = doc.data()!;
      final settingsData = data['notificationSettings'] as Map<String, dynamic>?;
      
      if (settingsData == null) {
        // Retornar configurações padrão
        return NotificationSettings.defaultSettings();
      }
      
      return NotificationSettings.fromFirestore(settingsData);
    } catch (e) {
      throw Exception('Erro ao buscar configurações de notificação: $e');
    }
  }

  @override
  Future<void> updateNotificationSettings(String driverId, NotificationSettings settings) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driverId)
          .update({
        'notificationSettings': settings.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar configurações de notificação: $e');
    }
  }
}