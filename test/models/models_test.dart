import 'package:flutter_test/flutter_test.dart';
import 'package:soroban/models/models.dart';

void main() {
  group('Models barrel export', () {
    test('should export all model classes', () {
      // Test that all classes are accessible through the barrel export

      // BeadModel and enums
      final bead = BeadModel(type: BeadType.heavenly, value: 5);
      expect(bead.position, BeadPosition.inactive);

      // RodModel
      final rod = RodModel.create(index: 0);
      expect(rod.heavenlyBead.type, BeadType.heavenly);

      // SorobanSettings and enum
      const settings = SorobanSettings(material: SorobanMaterial.marble);
      expect(settings.material, SorobanMaterial.marble);

      // SorobanModel
      final soroban = SorobanModel.create(settings: settings);
      expect(soroban.settings.material, SorobanMaterial.marble);
    });
  });
}
