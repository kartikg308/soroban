import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soroban/models/models.dart';

void main() {
  group('RodModel', () {
    test('should create a rod with correct basic properties', () {
      final heavenlyBead = BeadModel(type: BeadType.heavenly, value: 5);
      final earthlyBeads = List.generate(4, (_) => BeadModel(type: BeadType.earthly, value: 1));

      final rod = RodModel(index: 0, isUnitRod: false, heavenlyBead: heavenlyBead, earthlyBeads: earthlyBeads);

      expect(rod.index, 0);
      expect(rod.isUnitRod, false);
      expect(rod.heavenlyBead, heavenlyBead);
      expect(rod.earthlyBeads, earthlyBeads);
      expect(rod.earthlyBeads.length, 4);
    });

    test('should create a rod using factory constructor', () {
      final rod = RodModel.create(index: 5);

      expect(rod.index, 5);
      expect(rod.isUnitRod, true); // Index 5 should be a unit rod (every 3rd)
      expect(rod.heavenlyBead.type, BeadType.heavenly);
      expect(rod.heavenlyBead.value, 5);
      expect(rod.earthlyBeads.length, 4);

      for (final bead in rod.earthlyBeads) {
        expect(bead.type, BeadType.earthly);
        expect(bead.value, 1);
      }
    });

    test('should correctly identify unit rods', () {
      // Test unit rod pattern (every 3rd rod, 1-based indexing)
      expect(RodModel.create(index: 2).isUnitRod, true); // 3rd rod
      expect(RodModel.create(index: 5).isUnitRod, true); // 6th rod
      expect(RodModel.create(index: 8).isUnitRod, true); // 9th rod

      expect(RodModel.create(index: 0).isUnitRod, false); // 1st rod
      expect(RodModel.create(index: 1).isUnitRod, false); // 2nd rod
      expect(RodModel.create(index: 3).isUnitRod, false); // 4th rod
      expect(RodModel.create(index: 4).isUnitRod, false); // 5th rod
    });

    test('should validate heavenly bead type and value', () {
      final earthlyBeads = List.generate(4, (_) => BeadModel(type: BeadType.earthly, value: 1));

      expect(
        () => RodModel(
          index: 0,
          isUnitRod: false,
          heavenlyBead: BeadModel(type: BeadType.earthly, value: 1), // Wrong type
          earthlyBeads: earthlyBeads,
        ),
        throwsArgumentError,
      );

      expect(
        () => RodModel(
          index: 0,
          isUnitRod: false,
          heavenlyBead: BeadModel(type: BeadType.heavenly, value: 1), // Wrong value
          earthlyBeads: earthlyBeads,
        ),
        throwsArgumentError,
      );
    });

    test('should validate earthly beads count', () {
      final heavenlyBead = BeadModel(type: BeadType.heavenly, value: 5);

      expect(
        () => RodModel(
          index: 0,
          isUnitRod: false,
          heavenlyBead: heavenlyBead,
          earthlyBeads: [], // Wrong count
        ),
        throwsArgumentError,
      );

      expect(
        () => RodModel(
          index: 0,
          isUnitRod: false,
          heavenlyBead: heavenlyBead,
          earthlyBeads: List.generate(3, (_) => BeadModel(type: BeadType.earthly, value: 1)), // Wrong count
        ),
        throwsArgumentError,
      );
    });

    test('should validate earthly beads type and value', () {
      final heavenlyBead = BeadModel(type: BeadType.heavenly, value: 5);

      expect(
        () => RodModel(
          index: 0,
          isUnitRod: false,
          heavenlyBead: heavenlyBead,
          earthlyBeads: [
            BeadModel(type: BeadType.earthly, value: 1),
            BeadModel(type: BeadType.earthly, value: 1),
            BeadModel(type: BeadType.earthly, value: 1),
            BeadModel(type: BeadType.heavenly, value: 5), // Wrong type
          ],
        ),
        throwsArgumentError,
      );

      expect(
        () => RodModel(
          index: 0,
          isUnitRod: false,
          heavenlyBead: heavenlyBead,
          earthlyBeads: [
            BeadModel(type: BeadType.earthly, value: 1),
            BeadModel(type: BeadType.earthly, value: 1),
            BeadModel(type: BeadType.earthly, value: 1),
            BeadModel(type: BeadType.earthly, value: 2), // Wrong value
          ],
        ),
        throwsArgumentError,
      );
    });

    test('should return all beads correctly', () {
      final rod = RodModel.create(index: 0);
      final allBeads = rod.allBeads;

      expect(allBeads.length, 5);
      expect(allBeads[0], rod.heavenlyBead);
      expect(allBeads.sublist(1), rod.earthlyBeads);
    });

    test('should calculate current value correctly', () {
      final rod = RodModel.create(index: 0);

      // Initially all beads are inactive
      expect(rod.currentValue, 0);

      // Activate heavenly bead
      rod.heavenlyBead.setPosition(BeadPosition.active);
      expect(rod.currentValue, 5);

      // Activate one earthly bead
      rod.earthlyBeads[0].setPosition(BeadPosition.active);
      expect(rod.currentValue, 6);

      // Activate all earthly beads
      for (final bead in rod.earthlyBeads) {
        bead.setPosition(BeadPosition.active);
      }
      expect(rod.currentValue, 9); // 5 + 4
    });

    test('should count active earthly beads correctly', () {
      final rod = RodModel.create(index: 0);

      expect(rod.activeEarthlyBeadCount, 0);

      rod.earthlyBeads[0].setPosition(BeadPosition.active);
      expect(rod.activeEarthlyBeadCount, 1);

      rod.earthlyBeads[1].setPosition(BeadPosition.active);
      rod.earthlyBeads[2].setPosition(BeadPosition.active);
      expect(rod.activeEarthlyBeadCount, 3);
    });

    test('should check heavenly bead active state correctly', () {
      final rod = RodModel.create(index: 0);

      expect(rod.isHeavenlyBeadActive, false);

      rod.heavenlyBead.setPosition(BeadPosition.active);
      expect(rod.isHeavenlyBeadActive, true);
    });

    test('should reset all beads correctly', () {
      final rod = RodModel.create(index: 0);

      // Activate some beads
      rod.heavenlyBead.setPosition(BeadPosition.active);
      rod.earthlyBeads[0].setPosition(BeadPosition.active);
      rod.earthlyBeads[1].setPosition(BeadPosition.active);

      expect(rod.currentValue, 7);

      // Reset all beads
      rod.resetAllBeads();

      expect(rod.currentValue, 0);
      expect(rod.heavenlyBead.position, BeadPosition.inactive);
      for (final bead in rod.earthlyBeads) {
        expect(bead.position, BeadPosition.inactive);
      }
    });

    test('should set value correctly', () {
      final rod = RodModel.create(index: 0);

      // Test value 0
      rod.setValue(0);
      expect(rod.currentValue, 0);

      // Test value 3
      rod.setValue(3);
      expect(rod.currentValue, 3);
      expect(rod.isHeavenlyBeadActive, false);
      expect(rod.activeEarthlyBeadCount, 3);

      // Test value 5
      rod.setValue(5);
      expect(rod.currentValue, 5);
      expect(rod.isHeavenlyBeadActive, true);
      expect(rod.activeEarthlyBeadCount, 0);

      // Test value 7
      rod.setValue(7);
      expect(rod.currentValue, 7);
      expect(rod.isHeavenlyBeadActive, true);
      expect(rod.activeEarthlyBeadCount, 2);

      // Test value 9
      rod.setValue(9);
      expect(rod.currentValue, 9);
      expect(rod.isHeavenlyBeadActive, true);
      expect(rod.activeEarthlyBeadCount, 4);
    });

    test('should validate setValue input', () {
      final rod = RodModel.create(index: 0);

      expect(() => rod.setValue(-1), throwsArgumentError);
      expect(() => rod.setValue(10), throwsArgumentError);
    });

    test('should create correct copy with copyWith', () {
      final original = RodModel.create(index: 5);
      final newHeavenlyBead = BeadModel(type: BeadType.heavenly, value: 5);

      final copy = original.copyWith(index: 10, isUnitRod: false, heavenlyBead: newHeavenlyBead);

      expect(copy.index, 10);
      expect(copy.isUnitRod, false);
      expect(copy.heavenlyBead, newHeavenlyBead);
      expect(copy.earthlyBeads.length, 4);

      // Original should be unchanged
      expect(original.index, 5);
      expect(original.isUnitRod, true);
    });

    test('should implement equality correctly', () {
      final rod1 = RodModel.create(index: 0);
      final rod2 = RodModel.create(index: 0);
      final rod3 = RodModel.create(index: 1);

      expect(rod1, equals(rod2));
      expect(rod1, isNot(equals(rod3)));
      expect(rod1.hashCode, equals(rod2.hashCode));
    });

    test('should have meaningful toString representation', () {
      final rod = RodModel.create(index: 5);
      rod.setValue(7);

      final string = rod.toString();
      expect(string, contains('RodModel'));
      expect(string, contains('5'));
      expect(string, contains('true')); // isUnitRod
      expect(string, contains('7')); // value
    });

    test('should dispose resources correctly', () {
      final rod = RodModel.create(index: 0);

      // Test that dispose doesn't throw
      expect(() => rod.dispose(), returnsNormally);
    });
  });

  group('RodModel Position Management', () {
    late RodModel rod;
    late BeadPositionCalculator calculator;

    setUp(() {
      rod = RodModel.create(index: 0);
      const dimensions = RodDimensions(width: 100, height: 200, reckoningBarY: 80, heavenlyBeadRadius: 15, earthlyBeadRadius: 12, beadSpacing: 10);
      calculator = BeadPositionCalculator(dimensions);
    });

    test('should update bead positions correctly', () {
      // Set some beads to active
      rod.heavenlyBead.setPosition(BeadPosition.active);
      rod.earthlyBeads[0].setPosition(BeadPosition.active);
      rod.earthlyBeads[1].setPosition(BeadPosition.inactive);

      // Update positions using calculator
      rod.updateBeadPositions(calculator);

      // Check that positions were updated correctly
      expect(rod.heavenlyBead.currentOffset, calculator.getHeavenlyActivePosition());
      expect(rod.earthlyBeads[0].currentOffset, calculator.getEarthlyActivePosition(0));
      expect(rod.earthlyBeads[1].currentOffset, calculator.getEarthlyInactivePosition(1));
    });

    test('should validate bead positions correctly', () {
      // Set valid positions
      rod.heavenlyBead.updateOffset(calculator.getHeavenlyActivePosition());
      for (int i = 0; i < rod.earthlyBeads.length; i++) {
        rod.earthlyBeads[i].updateOffset(calculator.getEarthlyInactivePosition(i));
      }

      expect(rod.validateBeadPositions(calculator), true);

      // Set invalid position for heavenly bead
      rod.heavenlyBead.updateOffset(const Offset(5, 5)); // Outside bounds
      expect(rod.validateBeadPositions(calculator), false);

      // Reset to valid position
      rod.heavenlyBead.updateOffset(calculator.getHeavenlyActivePosition());
      expect(rod.validateBeadPositions(calculator), true);

      // Set invalid position for earthly bead
      rod.earthlyBeads[0].updateOffset(const Offset(5, 5)); // Outside bounds
      expect(rod.validateBeadPositions(calculator), false);
    });
  });
}
