/// Enum representing different soroban material themes
enum SorobanMaterial { traditionalWood, darkWood, marble, plastic, bamboo }

/// Model representing the settings and configuration for the soroban
class SorobanSettings {
  static const List<int> validRodCounts = [7, 13, 21, 23, 27, 31];
  static const double minAnimationSpeed = 0.5;
  static const double maxAnimationSpeed = 2.0;
  static const double minTouchSensitivity = 0.1;
  static const double maxTouchSensitivity = 2.0;

  final int numberOfRods;
  final SorobanMaterial material;
  final double animationSpeed;
  final double touchSensitivity;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool showUnitMarkers;

  const SorobanSettings({this.numberOfRods = 13, this.material = SorobanMaterial.traditionalWood, this.animationSpeed = 1.0, this.touchSensitivity = 1.0, this.soundEnabled = true, this.hapticEnabled = true, this.showUnitMarkers = true});

  /// Factory constructor for default settings
  factory SorobanSettings.defaultSettings() {
    return const SorobanSettings();
  }

  /// Validates the settings and throws an exception if invalid
  void validate() {
    if (!validRodCounts.contains(numberOfRods)) {
      throw ArgumentError('Number of rods must be one of: ${validRodCounts.join(', ')}');
    }

    if (animationSpeed < minAnimationSpeed || animationSpeed > maxAnimationSpeed) {
      throw ArgumentError('Animation speed must be between $minAnimationSpeed and $maxAnimationSpeed');
    }

    if (touchSensitivity < minTouchSensitivity || touchSensitivity > maxTouchSensitivity) {
      throw ArgumentError('Touch sensitivity must be between $minTouchSensitivity and $maxTouchSensitivity');
    }
  }

  /// Creates a copy of this settings object with optional parameter overrides
  SorobanSettings copyWith({int? numberOfRods, SorobanMaterial? material, double? animationSpeed, double? touchSensitivity, bool? soundEnabled, bool? hapticEnabled, bool? showUnitMarkers}) {
    final newSettings = SorobanSettings(
      numberOfRods: numberOfRods ?? this.numberOfRods,
      material: material ?? this.material,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      touchSensitivity: touchSensitivity ?? this.touchSensitivity,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      showUnitMarkers: showUnitMarkers ?? this.showUnitMarkers,
    );

    // Validate the new settings
    newSettings.validate();
    return newSettings;
  }

  /// Converts the settings to a Map for serialization
  Map<String, dynamic> toMap() {
    return {'numberOfRods': numberOfRods, 'material': material.name, 'animationSpeed': animationSpeed, 'touchSensitivity': touchSensitivity, 'soundEnabled': soundEnabled, 'hapticEnabled': hapticEnabled, 'showUnitMarkers': showUnitMarkers};
  }

  /// Creates settings from a Map (for deserialization)
  factory SorobanSettings.fromMap(Map<String, dynamic> map) {
    final materialName = map['material'] as String? ?? 'traditionalWood';
    final material = SorobanMaterial.values.firstWhere((m) => m.name == materialName, orElse: () => SorobanMaterial.traditionalWood);

    final settings = SorobanSettings(
      numberOfRods: map['numberOfRods'] as int? ?? 13,
      material: material,
      animationSpeed: (map['animationSpeed'] as num?)?.toDouble() ?? 1.0,
      touchSensitivity: (map['touchSensitivity'] as num?)?.toDouble() ?? 1.0,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      hapticEnabled: map['hapticEnabled'] as bool? ?? true,
      showUnitMarkers: map['showUnitMarkers'] as bool? ?? true,
    );

    settings.validate();
    return settings;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SorobanSettings &&
        other.numberOfRods == numberOfRods &&
        other.material == material &&
        other.animationSpeed == animationSpeed &&
        other.touchSensitivity == touchSensitivity &&
        other.soundEnabled == soundEnabled &&
        other.hapticEnabled == hapticEnabled &&
        other.showUnitMarkers == showUnitMarkers;
  }

  @override
  int get hashCode {
    return numberOfRods.hashCode ^ material.hashCode ^ animationSpeed.hashCode ^ touchSensitivity.hashCode ^ soundEnabled.hashCode ^ hapticEnabled.hashCode ^ showUnitMarkers.hashCode;
  }

  @override
  String toString() {
    return 'SorobanSettings('
        'numberOfRods: $numberOfRods, '
        'material: $material, '
        'animationSpeed: $animationSpeed, '
        'touchSensitivity: $touchSensitivity, '
        'soundEnabled: $soundEnabled, '
        'hapticEnabled: $hapticEnabled, '
        'showUnitMarkers: $showUnitMarkers'
        ')';
  }
}
