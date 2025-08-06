import 'rod_model.dart';
import 'soroban_settings.dart';

/// Main model representing the complete soroban abacus
class SorobanModel {
  final SorobanSettings settings;
  final List<RodModel> rods;

  SorobanModel({required this.settings, required this.rods}) {
    // Validate that the number of rods matches the settings
    if (rods.length != settings.numberOfRods) {
      throw ArgumentError('Number of rods (${rods.length}) does not match settings (${settings.numberOfRods})');
    }

    // Validate settings
    settings.validate();
  }

  /// Factory constructor to create a soroban with default configuration
  factory SorobanModel.create({SorobanSettings? settings}) {
    final sorobanSettings = settings ?? SorobanSettings.defaultSettings();

    final rods = List.generate(sorobanSettings.numberOfRods, (index) => RodModel.create(index: index));

    return SorobanModel(settings: sorobanSettings, rods: rods);
  }

  /// Gets the number of rods in this soroban
  int get numberOfRods => rods.length;

  /// Gets a specific rod by index
  RodModel getRod(int index) {
    if (index < 0 || index >= rods.length) {
      throw RangeError.index(index, rods, 'rod index');
    }
    return rods[index];
  }

  /// Gets all unit rods (rods with markers)
  List<RodModel> get unitRods => rods.where((rod) => rod.isUnitRod).toList();

  /// Gets the total value represented by all rods
  int get totalValue {
    int total = 0;
    for (int i = 0; i < rods.length; i++) {
      final rodValue = rods[i].currentValue;
      final placeValue = _calculatePlaceValue(i);
      total += rodValue * placeValue;
    }
    return total;
  }

  /// Calculates the place value for a rod at the given index
  /// (rightmost rod is ones place, next is tens, etc.)
  int _calculatePlaceValue(int rodIndex) {
    final placeFromRight = rods.length - 1 - rodIndex;
    return _pow(10, placeFromRight);
  }

  /// Helper method to calculate integer power
  int _pow(int base, int exponent) {
    if (exponent == 0) return 1;
    int result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  /// Sets the value of the soroban by distributing digits across rods
  void setValue(int value) {
    if (value < 0) {
      throw ArgumentError('Soroban value cannot be negative');
    }

    // Convert value to string to get individual digits
    final valueString = value.toString();
    final digits = valueString.split('').map(int.parse).toList();

    // Reset all rods first
    resetAllRods();

    // Set digits from right to left
    for (int i = 0; i < digits.length && i < rods.length; i++) {
      final rodIndex = rods.length - 1 - i;
      final digit = digits[digits.length - 1 - i];
      rods[rodIndex].setValue(digit);
    }
  }

  /// Resets all rods to zero (all beads inactive)
  void resetAllRods() {
    for (final rod in rods) {
      rod.resetAllBeads();
    }
  }

  /// Updates the settings and rebuilds the soroban if necessary
  SorobanModel updateSettings(SorobanSettings newSettings) {
    newSettings.validate();

    // If the number of rods changed, create a new soroban
    if (newSettings.numberOfRods != settings.numberOfRods) {
      return SorobanModel.create(settings: newSettings);
    }

    // Otherwise, just update the settings
    return copyWith(settings: newSettings);
  }

  /// Disposes of resources used by this soroban model
  void dispose() {
    for (final rod in rods) {
      rod.dispose();
    }
  }

  /// Creates a copy of this soroban model with optional parameter overrides
  SorobanModel copyWith({SorobanSettings? settings, List<RodModel>? rods}) {
    return SorobanModel(settings: settings ?? this.settings, rods: rods ?? List.from(this.rods));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SorobanModel && other.settings == settings && _listEquals(other.rods, rods);
  }

  @override
  int get hashCode {
    return settings.hashCode ^ rods.fold(0, (prev, rod) => prev ^ rod.hashCode);
  }

  @override
  String toString() {
    return 'SorobanModel(numberOfRods: $numberOfRods, totalValue: $totalValue, settings: $settings)';
  }

  /// Helper method to compare two lists for equality
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
