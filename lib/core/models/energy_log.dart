import 'package:uuid/uuid.dart';

// Energy level enum for post-session reflection
enum EnergyLevel {
  low,
  medium,
  high,
}

// Post-session reflection and energy tracking
class EnergyLog {
  final String id;
  final String sessionId; // Link to the focus session
  final EnergyLevel energyLevel;
  final String? reflectionNotes; // "What helped you focus?"
  final DateTime createdAt;

  EnergyLog({
    String? id,
    required this.sessionId,
    required this.energyLevel,
    this.reflectionNotes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Get emoji representation of energy level
  String get energyEmoji {
    switch (energyLevel) {
      case EnergyLevel.low:
        return '😴';
      case EnergyLevel.medium:
        return '😐';
      case EnergyLevel.high:
        return '🔥';
    }
  }

  // Get text representation
  String get energyLabel {
    switch (energyLevel) {
      case EnergyLevel.low:
        return 'Low';
      case EnergyLevel.medium:
        return 'Medium';
      case EnergyLevel.high:
        return 'High';
    }
  }

  EnergyLog copyWith({
    String? id,
    String? sessionId,
    EnergyLevel? energyLevel,
    String? reflectionNotes,
    DateTime? createdAt,
  }) {
    return EnergyLog(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      energyLevel: energyLevel ?? this.energyLevel,
      reflectionNotes: reflectionNotes ?? this.reflectionNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'EnergyLog(id: $id, sessionId: $sessionId, energy: ${energyLevel.name})';
}