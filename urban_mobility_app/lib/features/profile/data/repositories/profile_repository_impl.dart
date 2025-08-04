import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Temporariamente desabilitado
import '../models/user_profile.dart';
import 'profile_repository.dart';

/// Implementação do repositório de perfil usando Firebase
class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance; // Temporariamente desabilitado
  
  static const String _collection = 'user_profiles';

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!doc.exists) return null;
      
      return UserProfile.fromFirestore(doc, null);
    } catch (e) {
      throw ProfileException('Erro ao buscar perfil: ${e.toString()}');
    }
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _firestore
          .collection(_collection)
          .doc(profile.id)
          .set(updatedProfile.toFirestore(), SetOptions(merge: true));
      
      return updatedProfile;
    } catch (e) {
      throw ProfileException('Erro ao atualizar perfil: ${e.toString()}');
    }
  }

  @override
  Future<UserProfile> createProfile(UserProfile profile) async {
    try {
      final newProfile = profile.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestore
          .collection(_collection)
          .doc(profile.id)
          .set(newProfile.toFirestore());
      
      return newProfile;
    } catch (e) {
      throw ProfileException('Erro ao criar perfil: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProfile(String userId) async {
    try {
      // Deletar avatar se existir
      // try {
      //   await _storage.ref('avatars/$userId').delete();
      // } catch (e) {
      //   // Avatar pode não existir, ignorar erro
      // }
      
      // Deletar documentos se existirem
      // try {
      //   final docsRef = _storage.ref('documents/$userId');
      //   final result = await docsRef.listAll();
      //   for (final item in result.items) {
      //     await item.delete();
      //   }
      // } catch (e) {
      //   // Documentos podem não existir, ignorar erro
      // }
      
      // Deletar perfil
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw ProfileException('Erro ao deletar perfil: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadAvatar(String userId, File file) async {
    // Temporariamente desabilitado - FirebaseStorage não configurado
    throw ProfileException('Upload de avatar temporariamente indisponível');
    
    // try {
    //   final ref = _storage.ref('avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    //   
    //   final uploadTask = ref.putFile(
    //     file,
    //     SettableMetadata(
    //       contentType: 'image/jpeg',
    //       customMetadata: {
    //         'userId': userId,
    //         'uploadedAt': DateTime.now().toIso8601String(),
    //       },
    //     ),
    //   );
    //   
    //   final snapshot = await uploadTask;
    //   final downloadUrl = await snapshot.ref.getDownloadURL();
    //   
    //   return downloadUrl;
    // } catch (e) {
    //   throw ProfileException('Erro ao fazer upload do avatar: ${e.toString()}');
    // }
  }

  @override
  Future<void> removeAvatar(String userId) async {
    try {
      // Listar todos os avatars do usuário
      // final ref = _storage.ref('avatars/$userId');
      // final result = await ref.listAll();
      
      // Deletar todos os arquivos
      // for (final item in result.items) {
      //   await item.delete();
      // }
      
      // Atualizar perfil removendo a URL do avatar
      await _firestore.collection(_collection).doc(userId).update({
        'avatarUrl': FieldValue.delete(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw ProfileException('Erro ao remover avatar: ${e.toString()}');
    }
  }

  @override
  Stream<UserProfile?> watchProfile(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc, null);
    });
  }

  @override
  Future<List<UserProfile>> getNearbyDrivers(double lat, double lng, double radiusKm) async {
    try {
      // Para uma implementação completa, seria necessário usar geohash ou GeoFlutterFire
      // Por simplicidade, vamos buscar todos os motoristas ativos
      final query = await _firestore
          .collection(_collection)
          .where('userType', whereIn: ['driver', 'both'])
          .where('driverProfile.isAvailable', isEqualTo: true)
          .limit(20)
          .get();
      
      return query.docs
          .map((doc) => UserProfile.fromFirestore(doc, null))
          .toList();
    } catch (e) {
      throw ProfileException('Erro ao buscar motoristas próximos: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserLocation(String userId, double lat, double lng) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'location': GeoPoint(lat, lng),
        'lastActiveAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw ProfileException('Erro ao atualizar localização: ${e.toString()}');
    }
  }

  @override
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      final updateData = <String, dynamic>{
        'isOnline': isOnline,
        'updatedAt': Timestamp.now(),
      };
      
      if (isOnline) {
        updateData['lastActiveAt'] = Timestamp.now();
      }
      
      await _firestore.collection(_collection).doc(userId).update(updateData);
    } catch (e) {
      throw ProfileException('Erro ao atualizar status online: ${e.toString()}');
    }
  }
}

/// Exceção específica para operações de perfil
class ProfileException implements Exception {
  
  ProfileException(this.message);
  final String message;
  
  @override
  String toString() => message;
}