import 'package:flutter_test/flutter_test.dart';
import 'package:soroban/models/models.dart';

void main() {
  group('SorobanModel', () {
    test('should create soroban with correct basic properties', () {
      const settings = SorobanSettings(numberOfRods: 7);
      final rods = List.generate(7, (index) => RodModel.create(index: index));

      final soroban = SorobanModel(settings: settings, rods: rods);

      expect(soroban.settings, settings);
      expect(soroban.rods, rods);
      expect(soroban.numberOfRods, 7);
    });

    test('should create soroban using factory constructor', () {
      final soroban = SorobanModel.create();

      expect(soroban.numberOfRods, 13); // Default
      expect(soroban.settings.numberOfRods, 13);
      expect(soroban.rods.length, 13);

      // Check that rods are properly initialized
      for (int i = 0; i < 13; i++) {
        expect(soroban.rods[i].index, i);
        expect(soroban.rods[i].heavenlyBead.type, BeadType.heavenly);
        expect(soroban.rods[i].earthlyBeads.length, 4);
      }
    });

    test('should create soroban with custom settings', () {
      const customSettings = SorobanSettings(numberOfRods: 21, material: SorobanMaterial.marble);

      final soroban = SorobanModel.create(settings: customSettings);

      expect(soroban.numberOfRods, 21);
      expect(soroban.settings, customSettings);
      expect(soroban.rods.length, 21);
    });

    test('should validate rod count matches settings', () {
      const settings = SorobanSettings(numberOfRods: 7);
      final rods = List.generate(13, (index) => RodModel.create(index: index)); // Wrong count

      expect(() => SorobanModel(settings: settings, rods: rods), throwsArgumentError);
    });

    test('should get rod by index correctly', () {
      final soroban = SorobanModel.create();

      final rod = soroban.getRod(5);
      expect(rod.index, 5);

      expect(() => soroban.getRod(-1), throwsRangeError);
      expect(() => soroban.getRod(13), throwsRangeError);
    });

    test('should get unit rods correctly', () {
      final soroban = SorobanModel.create(settings: const SorobanSettings(numberOfRods: 13));

      final unitRods = soroban.unitRods;

      // Unit rods should be at indices 2, 5, 8, 11 (every 3rd, 0-based)
      expect(unitRods.length, 4);
      expect(unitRods.map((rod) => rod.index).toList(), [2, 5, 8, 11]);

      for (final rod in unitRods) {
        expect(rod.isUnitRod, true);
      }
    });

    test('should calculate total value correctly', () {
      final soroban = SorobanModel.create(settings: const SorobanSettings(numberOfRods: 7));

      // Initially all beads are inactive
      expect(soroban.totalValue, 0);

      // Set rightmost rod (ones place) to 5
      soroban.rods[6].setValue(5);
      expect(soroban.totalValue, 5);

      // Set second from right rod (tens place) to 3
      soroban.rods[5].setValue(3);
      expect(soroban.totalValue, 35);

      // Set third from right rod (hundreds place) to 7
      soroban.rods[4].setValue(7);
      expect(soroban.totalValue, 735);
    });

    test('should set value correctly', () {
      final soroban = SorobanModel.create(settings: const SorobanSettings(numberOfRods: 7));

      soroban.setValue(1234567);

      expect(soroban.rods[0].currentValue, 1); // Millions
      expect(soroban.rods[1].currentValue, 2); // Hundred thousands
      expect(soroban.rods[2].currentValue, 3); // Ten thousands
      expect(soroban.rods[3].currentValue, 4); // Thousands
      expect(soroban.rods[4].currentValue, 5); // Hundreds
      expect(soroban.rods[5].currentValue, 6); // Tens
      expect(soroban.rods[6].currentValue, 7); // Ones
      expect(soroban.totalValue, 1234567);
    });

    test('should set value with fewer digits than rods', () {
      final soroban = SorobanModel.create(settings: const SorobanSettings(numberOfRods: 7));

      soroban.setValue(123);

      expect(soroban.rods[0].currentValue, 0); // Millions
      expect(soroban.rods[1].currentValue, 0); // Hundred thousands
      expect(soroban.rods[2].currentValue, 0); // Ten thousands
      expect(soroban.rods[3].currentValue, 0); // Thousands
      expect(soroban.rods[4].currentValue, 1); // Hundreds
      expect(soroban.rods[5].currentValue, 2); // Tens
      expect(soroban.rods[6].currentValue, 3); // Ones
      expect(soroban.totalValue, 123);
    });

    test('should handle zero value correctly', () {
      final soroban = SorobanModel.create(settings: const SorobanSettings(numberOfRods: 7));

      // Set some values first
      soroban.setValue(123);
      expect(soroban.totalValue, 123);

      // Set to zero
      soroban.setValue(0);
      expect(soroban.totalValue, 0);

      for (final rod in soroban.rods) {
        expect(rod.currentValue, 0);
      }
    });

    test('should validate negative values', () {
      final soroban = SorobanModel.create();

      expect(() => soroban.setValue(-1), throwsArgumentError);
    });

    test('should reset all rods correctly', () {
      final soroban = SorobanModel.create(settings: const SorobanSettings(numberOfRods: 7));

      // Set some values
      soroban.setValue(789);
      expect(soroban.totalValue, 789);

      // Reset all rods
      soroban.resetAllRods();
      expect(soroban.totalValue, 0);

      for (final rod in soroban.rods) {
        expect(rod.currentValue, 0);
        expect(rod.heavenlyBead.position, BeadPosition.inactive);
        for (final bead in rod.earthlyBeads) {
          expect(bead.position, BeadPosition.inactive);
        }
      }
    });

    test('should update settings without changing rod count', () {
      final soroban = SorobanModel.create();
      soroban.setValue(123);

      final newSettings = soroban.settings.copyWith(material: SorobanMaterial.marble, soundEnabled: false);

      final updatedSoroban = soroban.updateSettings(newSettings);

      expect(updatedSoroban.settings.material, SorobanMaterial.marble);
      expect(updatedSoroban.settings.soundEnabled, false);
      expect(updatedSoroban.numberOfRods, 13); // Same as original
      expect(updatedSoroban.totalValue, 123); // Value preserved
    });

    test('should update settings with different rod count', () {
      final soroban = SorobanModel.create();
      soroban.setValue(123);

      final newSettings = soroban.settings.copyWith(numberOfRods: 21);
      final updatedSoroban = soroban.updateSettings(newSettings);

      expect(updatedSoroban.numberOfRods, 21);
      expect(updatedSoroban.totalValue, 0); // New soroban, reset value
    });

    test('should create copy with copyWith', () {
      final original = SorobanModel.create();
      original.setValue(123);

      const newSettings = SorobanSettings(numberOfRods: 13, material: SorobanMaterial.marble);

      final copy = original.copyWith(settings: newSettings);

      expect(copy.settings.material, SorobanMaterial.marble);
      expect(copy.numberOfRods, 13);
      expect(copy.totalValue, 123); // Value preserved

      // Original should be unchanged
      expect(original.settings.material, SorobanMaterial.traditionalWood);
    });

    test('should implement equality correctly', () {
      final soroban1 = SorobanModel.create();
      final soroban2 = SorobanModel.create();
      final soroban3 = SorobanModel.create(settings: const SorobanSettings(numberOfRods: 21));

      expect(soroban1, equals(soroban2));
      expect(soroban1, isNot(equals(soroban3)));
      expect(soroban1.hashCode, equals(soroban2.hashCode));
    });

    test('should have meaningful toString representation', () {
      final soroban = SorobanModel.create();
      soroban.setValue(123);

      final string = soroban.toString();
      expect(string, contains('SorobanModel'));
      expect(string, contains('13')); // numberOfRods
      expect(string, contains('123')); // totalValue
    });

    test('should dispose resources correctly', () {
      final soroban = SorobanModel.create();

      // Test that dispose doesn't throw
      expect(() => soroban.dispose(), returnsNormally);
    });

    test('should handle large values correctly', () {
      final soroban = SorobanModel.create(settings: const SorobanSettings(numberOfRods: 7));

      soroban.setValue(1234567);

      expect(soroban.rods[0].currentValue, 1);
      expect(soroban.rods[1].currentValue, 2);
      expect(soroban.rods[2].currentValue, 3);
      expect(soroban.rods[3].currentValue, 4);
      expect(soroban.rods[4].currentValue, 5);
      expect(soroban.rods[5].currentValue, 6);
      expect(soroban.rods[6].currentValue, 7);
      expect(soroban.totalValue, 1234567);
    });

    test('should handle values larger than rod capacity', () {
      final soroban = SorobanModel.create(settings: const SorobanSettings(numberOfRods: 7));

      // Value has more digits than rods - should only set the rightmost digits
      soroban.setValue(12345678);

      expect(soroban.rods[0].currentValue, 2); // Millions
      expect(soroban.rods[1].currentValue, 3); // Hundred thousands
      expect(soroban.rods[2].currentValue, 4); // Ten thousands
      expect(soroban.rods[3].currentValue, 5); // Thousands
      expect(soroban.rods[4].currentValue, 6); // Hundreds
      expect(soroban.rods[5].currentValue, 7); // Tens
      expect(soroban.rods[6].currentValue, 8); // Ones
      expect(soroban.totalValue, 2345678);
    });
  });
}
