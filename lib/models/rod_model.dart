import 'bead_model.dart';
import 'bead_position_calculator.dart';

/// Model representing a single rod in the soroban
class RodModel {
  final int index;
  final bool isUnitRod;
  final BeadModel heavenlyBead;
  final List<BeadModel> earthlyBeads;

  RodModel({required this.index, required this.isUnitRod, required this.heavenlyBead, required this.earthlyBeads}) {
    // Validate that we have exactly 4 earthly beads
    if (earthlyBeads.length != 4) {
      throw ArgumentError('A rod must have exactly 4 earthly beads');
    }

    // Validate that the heavenly bead is of the correct type and value
    if (heavenlyBead.type != BeadType.heavenly || heavenlyBead.value != 5) {
      throw ArgumentError('Heavenly bead must be of type heavenly with value 5');
    }

    // Validate that all earthly beads are of the correct type and value
    for (final bead in earthlyBeads) {
      if (bead.type != BeadType.earthly || bead.value != 1) {
        throw ArgumentError('Earthly beads must be of type earthly with value 1');
      }
    }
  }

  /// Factory constructor to create a rod with default bead configuration
  factory RodModel.create({required int index, bool? isUnitRod}) {
    // Unit rods are every third rod (indices 2, 5, 8, etc. for 0-based indexing)
    final unitRod = isUnitRod ?? ((index + 1) % 3 == 0);

    final heavenlyBead = BeadModel(type: BeadType.heavenly, value: 5);

    final earthlyBeads = List.generate(4, (beadIndex) => BeadModel(type: BeadType.earthly, value: 1));

    return RodModel(index: index, isUnitRod: unitRod, heavenlyBead: heavenlyBead, earthlyBeads: earthlyBeads);
  }

  /// Gets all beads in this rod (heavenly + earthly)
  List<BeadModel> get allBeads => [heavenlyBead, ...earthlyBeads];

  /// Gets the current value represented by this rod
  int get currentValue {
    int value = 0;

    // Add heavenly bead value if active
    if (heavenlyBead.isActive) {
      value += heavenlyBead.value;
    }

    // Add earthly bead values if active
    for (final bead in earthlyBeads) {
      if (bead.isActive) {
        value += bead.value;
      }
    }

    return value;
  }

  /// Gets the number of active earthly beads
  int get activeEarthlyBeadCount {
    return earthlyBeads.where((bead) => bead.isActive).length;
  }

  /// Checks if the heavenly bead is active
  bool get isHeavenlyBeadActive => heavenlyBead.isActive;

  /// Resets all beads in this rod to inactive position
  void resetAllBeads() {
    heavenlyBead.setPosition(BeadPosition.inactive);
    for (final bead in earthlyBeads) {
      bead.setPosition(BeadPosition.inactive);
    }
  }

  /// Sets the value of this rod by activating the appropriate beads
  void setValue(int value) {
    if (value < 0 || value > 9) {
      throw ArgumentError('Rod value must be between 0 and 9');
    }

    // Reset all beads first
    resetAllBeads();

    // Activate heavenly bead if value >= 5
    if (value >= 5) {
      heavenlyBead.setPosition(BeadPosition.active);
      value -= 5;
    }

    // Activate earthly beads for remaining value
    for (int i = 0; i < value && i < earthlyBeads.length; i++) {
      earthlyBeads[i].setPosition(BeadPosition.active);
    }
  }

  /// Disposes of resources used by this rod model
  void dispose() {
    heavenlyBead.dispose();
    for (final bead in earthlyBeads) {
      bead.dispose();
    }
  }

  /// Updates bead positions using the position calculator
  void updateBeadPositions(BeadPositionCalculator calculator) {
    // Update heavenly bead position
    final heavenlyTargetPos = calculator.getTargetPosition(BeadType.heavenly, 0, heavenlyBead.position);
    heavenlyBead.updateOffset(heavenlyTargetPos);

    // Update earthly bead positions
    for (int i = 0; i < earthlyBeads.length; i++) {
      final earthlyTargetPos = calculator.getTargetPosition(BeadType.earthly, i, earthlyBeads[i].position);
      earthlyBeads[i].updateOffset(earthlyTargetPos);
    }
  }

  /// Validates all bead positions are within bounds
  bool validateBeadPositions(BeadPositionCalculator calculator) {
    // Check heavenly bead
    if (!calculator.isPositionValid(BeadType.heavenly, heavenlyBead.currentOffset)) {
      return false;
    }

    // Check earthly beads
    for (final bead in earthlyBeads) {
      if (!calculator.isPositionValid(BeadType.earthly, bead.currentOffset)) {
        return false;
      }
    }

    return true;
  }

  /// Creates a copy of this rod model with optional parameter overrides
  RodModel copyWith({int? index, bool? isUnitRod, BeadModel? heavenlyBead, List<BeadModel>? earthlyBeads}) {
    return RodModel(index: index ?? this.index, isUnitRod: isUnitRod ?? this.isUnitRod, heavenlyBead: heavenlyBead ?? this.heavenlyBead, earthlyBeads: earthlyBeads ?? List.from(this.earthlyBeads));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RodModel && other.index == index && other.isUnitRod == isUnitRod && other.heavenlyBead == heavenlyBead && _listEquals(other.earthlyBeads, earthlyBeads);
  }

  @override
  int get hashCode {
    return index.hashCode ^ isUnitRod.hashCode ^ heavenlyBead.hashCode ^ earthlyBeads.fold(0, (prev, bead) => prev ^ bead.hashCode);
  }

  @override
  String toString() {
    return 'RodModel(index: $index, isUnitRod: $isUnitRod, value: $currentValue)';
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
