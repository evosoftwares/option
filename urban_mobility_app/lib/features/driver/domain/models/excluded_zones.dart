/// Áreas de Atendimento - Zonas de Exclusão (Seção 4.2)
/// Implementa a funcionalidade de excluir bairros/zonas específicas
class ExcludedZones {
  const ExcludedZones({required this.neighborhoods, required this.lastUpdated});

  /// Lista de bairros/zonas excluídas
  final List<ExcludedNeighborhood> neighborhoods;

  /// Última atualização da lista
  final DateTime lastUpdated;

  /// Verifica se um bairro está na lista de exclusão
  bool isExcluded(String neighborhoodName, String city) {
    return neighborhoods.any(
      (excluded) =>
          excluded.name.toLowerCase() == neighborhoodName.toLowerCase() &&
          excluded.city.toLowerCase() == city.toLowerCase(),
    );
  }

  /// Verifica se uma viagem deve ser excluída baseada na origem ou destino
  bool shouldExcludeTrip({
    required String originNeighborhood,
    required String originCity,
    required String destinationNeighborhood,
    required String destinationCity,
  }) {
    // Conforme regras: exclui se origem OU destino estiver na lista
    return isExcluded(originNeighborhood, originCity) ||
        isExcluded(destinationNeighborhood, destinationCity);
  }

  /// Adiciona um bairro à lista de exclusão
  ExcludedZones addNeighborhood(ExcludedNeighborhood neighborhood) {
    final updatedList = List<ExcludedNeighborhood>.from(neighborhoods);

    // Evita duplicatas
    if (!updatedList.any(
      (n) =>
          n.name.toLowerCase() == neighborhood.name.toLowerCase() &&
          n.city.toLowerCase() == neighborhood.city.toLowerCase(),
    )) {
      updatedList.add(neighborhood);
    }

    return ExcludedZones(
      neighborhoods: updatedList,
      lastUpdated: DateTime.now(),
    );
  }

  /// Remove um bairro da lista de exclusão
  ExcludedZones removeNeighborhood(String neighborhoodName, String city) {
    final updatedList = neighborhoods
        .where(
          (n) =>
              !(n.name.toLowerCase() == neighborhoodName.toLowerCase() &&
                  n.city.toLowerCase() == city.toLowerCase()),
        )
        .toList();

    return ExcludedZones(
      neighborhoods: updatedList,
      lastUpdated: DateTime.now(),
    );
  }

  factory ExcludedZones.fromJson(Map<String, dynamic> json) {
    return ExcludedZones(
      neighborhoods: (json['neighborhoods'] as List<dynamic>)
          .map(
            (item) =>
                ExcludedNeighborhood.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'neighborhoods': neighborhoods.map((n) => n.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Lista vazia de zonas excluídas
  factory ExcludedZones.empty() {
    return ExcludedZones(neighborhoods: const [], lastUpdated: DateTime.now());
  }

  /// Número de bairros excluídos
  int get count => neighborhoods.length;

  /// Se há bairros excluídos
  bool get hasExclusions => neighborhoods.isNotEmpty;
}

/// Bairro/Zona Excluída
class ExcludedNeighborhood {
  const ExcludedNeighborhood({
    required this.name,
    required this.city,
    required this.state,
    required this.addedAt,
    this.reason,
  });

  final String name;
  final String city;
  final String state;
  final DateTime addedAt;
  final String? reason; // Motivo da exclusão (opcional)

  /// Nome completo formatado
  String get fullName => '$name, $city - $state';

  factory ExcludedNeighborhood.fromJson(Map<String, dynamic> json) {
    return ExcludedNeighborhood(
      name: json['name'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'state': state,
      'addedAt': addedAt.toIso8601String(),
      'reason': reason,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExcludedNeighborhood &&
        other.name.toLowerCase() == name.toLowerCase() &&
        other.city.toLowerCase() == city.toLowerCase() &&
        other.state.toLowerCase() == state.toLowerCase();
  }

  @override
  int get hashCode =>
      Object.hash(name.toLowerCase(), city.toLowerCase(), state.toLowerCase());
}
