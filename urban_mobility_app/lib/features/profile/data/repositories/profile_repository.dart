import 'dart:io';
import '../models/user_profile.dart';

/// Interface do repositório de perfil
abstract class ProfileRepository {
  /// Busca o perfil do usuário por ID
  Future<UserProfile?> getProfile(String userId);
  
  /// Atualiza o perfil do usuário
  Future<UserProfile> updateProfile(UserProfile profile);
  
  /// Cria um novo perfil
  Future<UserProfile> createProfile(UserProfile profile);
  
  /// Deleta o perfil do usuário
  Future<void> deleteProfile(String userId);
  
  /// Upload de avatar
  Future<String> uploadAvatar(String userId, File file);
  
  /// Remove avatar
  Future<void> removeAvatar(String userId);
  
  /// Stream de mudanças no perfil
  Stream<UserProfile?> watchProfile(String userId);
  
  /// Busca perfis próximos (para motoristas)
  Future<List<UserProfile>> getNearbyDrivers(double lat, double lng, double radiusKm);
  
  /// Atualiza localização do usuário
  Future<void> updateUserLocation(String userId, double lat, double lng);
  
  /// Atualiza status online/offline
  Future<void> updateOnlineStatus(String userId, bool isOnline);
}