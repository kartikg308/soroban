import 'package:flutter_test/flutter_test.dart';
import 'package:soroban/models/models.dart';

void main() {
  group('SorobanSettings', () {
    test('should create settings with default values', () {
      const settings = SorobanSettings();

      expect(settings.numberOfRods, 13);
      expect(settings.material, SorobanMaterial.traditionalWood);
      expect(settings.animationSpeed, 1.0);
      expect(settings.touchSensitivity, 1.0);
      expect(settings.soundEnabled, true);
      expect(settings.hapticEnabled, true);
      expect(settings.showUnitMarkers, true);
    });

    test('should create settings with custom values', () {
      const settings = SorobanSettings(numberOfRods: 21, material: SorobanMaterial.marble, animationSpeed: 1.5, touchSensitivity: 0.8, soundEnabled: false, hapticEnabled: false, showUnitMarkers: false);

      expect(settings.numberOfRods, 21);
      expect(settings.material, SorobanMaterial.marble);
      expect(settings.animationSpeed, 1.5);
      expect(settings.touchSensitivity, 0.8);
      expect(settings.soundEnabled, false);
      expect(settings.hapticEnabled, false);
      expect(settings.showUnitMarkers, false);
    });

    test('should create default settings using factory', () {
      final settings = SorobanSettings.defaultSettings();

      expect(settings.numberOfRods, 13);
      expect(settings.material, SorobanMaterial.traditionalWood);
      expect(settings.animationSpeed, 1.0);
      expect(settings.touchSensitivity, 1.0);
      expect(settings.soundEnabled, true);
      expect(settings.hapticEnabled, true);
      expect(settings.showUnitMarkers, true);
    });

    test('should validate valid settings', () {
      const settings = SorobanSettings(numberOfRods: 13, animationSpeed: 1.0, touchSensitivity: 1.0);

      expect(() => settings.validate(), returnsNormally);
    });

    test('should validate numberOfRods', () {
      // Valid rod counts
      for (final count in SorobanSettings.validRodCounts) {
        final settings = SorobanSettings(numberOfRods: count);
        expect(() => settings.validate(), returnsNormally);
      }

      // Invalid rod counts
      const invalidSettings1 = SorobanSettings(numberOfRods: 5);
      expect(() => invalidSettings1.validate(), throwsArgumentError);

      const invalidSettings2 = SorobanSettings(numberOfRods: 15);
      expect(() => invalidSettings2.validate(), throwsArgumentError);
    });

    test('should validate animationSpeed', () {
      // Valid speeds
      const validSettings1 = SorobanSettings(animationSpeed: 0.5);
      expect(() => validSettings1.validate(), returnsNormally);

      const validSettings2 = SorobanSettings(animationSpeed: 2.0);
      expect(() => validSettings2.validate(), returnsNormally);

      // Invalid speeds
      const invalidSettings1 = SorobanSettings(animationSpeed: 0.4);
      expect(() => invalidSettings1.validate(), throwsArgumentError);

      const invalidSettings2 = SorobanSettings(animationSpeed: 2.1);
      expect(() => invalidSettings2.validate(), throwsArgumentError);
    });

    test('should validate touchSensitivity', () {
      // Valid sensitivity
      const validSettings1 = SorobanSettings(touchSensitivity: 0.1);
      expect(() => validSettings1.validate(), returnsNormally);

      const validSettings2 = SorobanSettings(touchSensitivity: 2.0);
      expect(() => validSettings2.validate(), returnsNormally);

      // Invalid sensitivity
      const invalidSettings1 = SorobanSettings(touchSensitivity: 0.05);
      expect(() => invalidSettings1.validate(), throwsArgumentError);

      const invalidSettings2 = SorobanSettings(touchSensitivity: 2.1);
      expect(() => invalidSettings2.validate(), throwsArgumentError);
    });

    test('should create copy with copyWith', () {
      const original = SorobanSettings(numberOfRods: 13, material: SorobanMaterial.traditionalWood, soundEnabled: true);

      final copy = original.copyWith(numberOfRods: 21, material: SorobanMaterial.marble, soundEnabled: false);

      expect(copy.numberOfRods, 21);
      expect(copy.material, SorobanMaterial.marble);
      expect(copy.soundEnabled, false);
      expect(copy.animationSpeed, 1.0); // Unchanged
      expect(copy.touchSensitivity, 1.0); // Unchanged
      expect(copy.hapticEnabled, true); // Unchanged
      expect(copy.showUnitMarkers, true); // Unchanged

      // Original should be unchanged
      expect(original.numberOfRods, 13);
      expect(original.material, SorobanMaterial.traditionalWood);
      expect(original.soundEnabled, true);
    });

    test('should validate when creating copy with copyWith', () {
      const original = SorobanSettings();

      expect(
        () => original.copyWith(numberOfRods: 5), // Invalid
        throwsArgumentError,
      );

      expect(
        () => original.copyWith(animationSpeed: 0.4), // Invalid
        throwsArgumentError,
      );
    });

    test('should convert to map correctly', () {
      const settings = SorobanSettings(numberOfRods: 21, material: SorobanMaterial.marble, animationSpeed: 1.5, touchSensitivity: 0.8, soundEnabled: false, hapticEnabled: false, showUnitMarkers: false);

      final map = settings.toMap();

      expect(map['numberOfRods'], 21);
      expect(map['material'], 'marble');
      expect(map['animationSpeed'], 1.5);
      expect(map['touchSensitivity'], 0.8);
      expect(map['soundEnabled'], false);
      expect(map['hapticEnabled'], false);
      expect(map['showUnitMarkers'], false);
    });

    test('should create from map correctly', () {
      final map = {'numberOfRods': 21, 'material': 'marble', 'animationSpeed': 1.5, 'touchSensitivity': 0.8, 'soundEnabled': false, 'hapticEnabled': false, 'showUnitMarkers': false};

      final settings = SorobanSettings.fromMap(map);

      expect(settings.numberOfRods, 21);
      expect(settings.material, SorobanMaterial.marble);
      expect(settings.animationSpeed, 1.5);
      expect(settings.touchSensitivity, 0.8);
      expect(settings.soundEnabled, false);
      expect(settings.hapticEnabled, false);
      expect(settings.showUnitMarkers, false);
    });

    test('should create from map with missing values using defaults', () {
      final map = <String, dynamic>{'numberOfRods': 21};

      final settings = SorobanSettings.fromMap(map);

      expect(settings.numberOfRods, 21);
      expect(settings.material, SorobanMaterial.traditionalWood);
      expect(settings.animationSpeed, 1.0);
      expect(settings.touchSensitivity, 1.0);
      expect(settings.soundEnabled, true);
      expect(settings.hapticEnabled, true);
      expect(settings.showUnitMarkers, true);
    });

    test('should handle invalid material name in fromMap', () {
      final map = {'material': 'invalidMaterial'};

      final settings = SorobanSettings.fromMap(map);
      expect(settings.material, SorobanMaterial.traditionalWood);
    });

    test('should validate settings created from map', () {
      final invalidMap = {
        'numberOfRods': 5, // Invalid
      };

      expect(() => SorobanSettings.fromMap(invalidMap), throwsArgumentError);
    });

    test('should implement equality correctly', () {
      const settings1 = SorobanSettings(numberOfRods: 21, material: SorobanMaterial.marble, animationSpeed: 1.5);

      const settings2 = SorobanSettings(numberOfRods: 21, material: SorobanMaterial.marble, animationSpeed: 1.5);

      const settings3 = SorobanSettings(numberOfRods: 13, material: SorobanMaterial.marble, animationSpeed: 1.5);

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('should have meaningful toString representation', () {
      const settings = SorobanSettings(numberOfRods: 21, material: SorobanMaterial.marble, animationSpeed: 1.5);

      final string = settings.toString();
      expect(string, contains('SorobanSettings'));
      expect(string, contains('21'));
      expect(string, contains('marble'));
      expect(string, contains('1.5'));
    });
  });

  group('SorobanMaterial enum', () {
    test('should have correct values', () {
      expect(SorobanMaterial.values.length, 5);
      expect(SorobanMaterial.values, contains(SorobanMaterial.traditionalWood));
      expect(SorobanMaterial.values, contains(SorobanMaterial.darkWood));
      expect(SorobanMaterial.values, contains(SorobanMaterial.marble));
      expect(SorobanMaterial.values, contains(SorobanMaterial.plastic));
      expect(SorobanMaterial.values, contains(SorobanMaterial.bamboo));
    });

    test('should have correct names', () {
      expect(SorobanMaterial.traditionalWood.name, 'traditionalWood');
      expect(SorobanMaterial.darkWood.name, 'darkWood');
      expect(SorobanMaterial.marble.name, 'marble');
      expect(SorobanMaterial.plastic.name, 'plastic');
      expect(SorobanMaterial.bamboo.name, 'bamboo');
    });
  });
}
