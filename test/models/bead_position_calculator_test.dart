import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soroban/models/models.dart';

void main() {
  group('RodDimensions', () {
    test('should calculate heavenly section correctly', () {
      const dimensions = RodDimensions(width: 100, height: 200, reckoningBarY: 80, heavenlyBeadRadius: 15, earthlyBeadRadius: 12, beadSpacing: 10);

      expect(dimensions.heavenlySection, 80);
    });

    test('should calculate earthly section correctly', () {
      const dimensions = RodDimensions(width: 100, height: 200, reckoningBarY: 80, heavenlyBeadRadius: 15, earthlyBeadRadius: 12, beadSpacing: 10);

      expect(dimensions.earthlySection, 120);
    });
  });

  group('BeadPositionCalculator', () {
    late RodDimensions dimensions;
    late BeadPositionCalculator calculator;

    setUp(() {
      dimensions = const RodDimensions(width: 100, height: 200, reckoningBarY: 80, heavenlyBeadRadius: 15, earthlyBeadRadius: 12, beadSpacing: 10);
      calculator = BeadPositionCalculator(dimensions);
    });

    group('Heavenly bead positions', () {
      test('should calculate active position correctly', () {
        final position = calculator.getHeavenlyActivePosition();

        expect(position.dx, 50); // width / 2
        expect(position.dy, 65); // reckoningBarY - radius
      });

      test('should calculate inactive position correctly', () {
        final position = calculator.getHeavenlyInactivePosition();

        expect(position.dx, 50); // width / 2
        expect(position.dy, 25); // radius + spacing
      });
    });

    group('Earthly bead positions', () {
      test('should calculate active positions correctly', () {
        for (int i = 0; i < 4; i++) {
          final position = calculator.getEarthlyActivePosition(i);

          expect(position.dx, 50); // width / 2
          expect(position.dy, 92 + (i * 10)); // reckoningBarY + radius + (index * spacing)
        }
      });

      test('should calculate inactive positions correctly', () {
        for (int i = 0; i < 4; i++) {
          final position = calculator.getEarthlyInactivePosition(i);

          expect(position.dx, 50); // width / 2
          expect(position.dy, 178 - (i * 10)); // height - radius - spacing - (index * spacing)
        }
      });

      test('should throw error for invalid earthly bead index', () {
        expect(() => calculator.getEarthlyActivePosition(-1), throwsArgumentError);
        expect(() => calculator.getEarthlyActivePosition(4), throwsArgumentError);
        expect(() => calculator.getEarthlyInactivePosition(-1), throwsArgumentError);
        expect(() => calculator.getEarthlyInactivePosition(4), throwsArgumentError);
      });
    });

    group('Target position calculation', () {
      test('should return correct target positions for heavenly beads', () {
        final activePos = calculator.getTargetPosition(BeadType.heavenly, 0, BeadPosition.active);
        final inactivePos = calculator.getTargetPosition(BeadType.heavenly, 0, BeadPosition.inactive);

        expect(activePos, calculator.getHeavenlyActivePosition());
        expect(inactivePos, calculator.getHeavenlyInactivePosition());
      });

      test('should return correct target positions for earthly beads', () {
        for (int i = 0; i < 4; i++) {
          final activePos = calculator.getTargetPosition(BeadType.earthly, i, BeadPosition.active);
          final inactivePos = calculator.getTargetPosition(BeadType.earthly, i, BeadPosition.inactive);

          expect(activePos, calculator.getEarthlyActivePosition(i));
          expect(inactivePos, calculator.getEarthlyInactivePosition(i));
        }
      });

      test('should throw error for moving position', () {
        expect(() => calculator.getTargetPosition(BeadType.heavenly, 0, BeadPosition.moving), throwsArgumentError);
        expect(() => calculator.getTargetPosition(BeadType.earthly, 0, BeadPosition.moving), throwsArgumentError);
      });
    });

    group('Position validation', () {
      test('should validate heavenly bead positions correctly', () {
        // Valid positions
        expect(calculator.isPositionValid(BeadType.heavenly, const Offset(50, 40)), true);
        expect(calculator.isPositionValid(BeadType.heavenly, const Offset(20, 30)), true);
        expect(calculator.isPositionValid(BeadType.heavenly, const Offset(80, 60)), true);

        // Invalid positions - outside horizontal bounds
        expect(calculator.isPositionValid(BeadType.heavenly, const Offset(10, 40)), false);
        expect(calculator.isPositionValid(BeadType.heavenly, const Offset(95, 40)), false);

        // Invalid positions - outside vertical bounds
        expect(calculator.isPositionValid(BeadType.heavenly, const Offset(50, 10)), false);
        expect(calculator.isPositionValid(BeadType.heavenly, const Offset(50, 70)), false);
      });

      test('should validate earthly bead positions correctly', () {
        // Valid positions
        expect(calculator.isPositionValid(BeadType.earthly, const Offset(50, 100)), true);
        expect(calculator.isPositionValid(BeadType.earthly, const Offset(30, 150)), true);
        expect(calculator.isPositionValid(BeadType.earthly, const Offset(70, 180)), true);

        // Invalid positions - outside horizontal bounds
        expect(calculator.isPositionValid(BeadType.earthly, const Offset(8, 100)), false);
        expect(calculator.isPositionValid(BeadType.earthly, const Offset(95, 100)), false);

        // Invalid positions - outside vertical bounds
        expect(calculator.isPositionValid(BeadType.earthly, const Offset(50, 85)), false);
        expect(calculator.isPositionValid(BeadType.earthly, const Offset(50, 195)), false);
      });
    });

    group('Position constraining', () {
      test('should constrain heavenly bead positions correctly', () {
        // Test horizontal constraining
        final constrainedLeft = calculator.constrainPosition(BeadType.heavenly, const Offset(5, 40));
        expect(constrainedLeft.dx, 15); // radius
        expect(constrainedLeft.dy, 40);

        final constrainedRight = calculator.constrainPosition(BeadType.heavenly, const Offset(95, 40));
        expect(constrainedRight.dx, 85); // width - radius
        expect(constrainedRight.dy, 40);

        // Test vertical constraining
        final constrainedTop = calculator.constrainPosition(BeadType.heavenly, const Offset(50, 5));
        expect(constrainedTop.dx, 50);
        expect(constrainedTop.dy, 15); // radius

        final constrainedBottom = calculator.constrainPosition(BeadType.heavenly, const Offset(50, 75));
        expect(constrainedBottom.dx, 50);
        expect(constrainedBottom.dy, 65); // reckoningBarY - radius
      });

      test('should constrain earthly bead positions correctly', () {
        // Test horizontal constraining
        final constrainedLeft = calculator.constrainPosition(BeadType.earthly, const Offset(5, 100));
        expect(constrainedLeft.dx, 12); // radius
        expect(constrainedLeft.dy, 100);

        final constrainedRight = calculator.constrainPosition(BeadType.earthly, const Offset(95, 100));
        expect(constrainedRight.dx, 88); // width - radius
        expect(constrainedRight.dy, 100);

        // Test vertical constraining
        final constrainedTop = calculator.constrainPosition(BeadType.earthly, const Offset(50, 85));
        expect(constrainedTop.dx, 50);
        expect(constrainedTop.dy, 92); // reckoningBarY + radius

        final constrainedBottom = calculator.constrainPosition(BeadType.earthly, const Offset(50, 195));
        expect(constrainedBottom.dx, 50);
        expect(constrainedBottom.dy, 188); // height - radius
      });
    });

    group('Position state determination', () {
      test('should determine heavenly bead states correctly', () {
        // Near active position
        final nearActive = calculator.determinePositionState(
          BeadType.heavenly,
          const Offset(50, 67), // Close to active position (65)
        );
        expect(nearActive, BeadPosition.active);

        // Near inactive position
        final nearInactive = calculator.determinePositionState(
          BeadType.heavenly,
          const Offset(50, 27), // Close to inactive position (25)
        );
        expect(nearInactive, BeadPosition.inactive);

        // Far from both positions
        final farFromBoth = calculator.determinePositionState(
          BeadType.heavenly,
          const Offset(50, 45), // Middle position
        );
        expect(farFromBoth, BeadPosition.moving);
      });

      test('should determine earthly bead states correctly', () {
        // Near active position (using first bead position as reference)
        final nearActive = calculator.determinePositionState(
          BeadType.earthly,
          const Offset(50, 94), // Close to first active position (92)
        );
        expect(nearActive, BeadPosition.active);

        // Near inactive position (using first bead position as reference)
        final nearInactive = calculator.determinePositionState(
          BeadType.earthly,
          const Offset(50, 176), // Close to first inactive position (178)
        );
        expect(nearInactive, BeadPosition.inactive);

        // Far from both positions - let's calculate a position that's truly in the middle
        // Active positions are at: 92, 102, 112, 122
        // Inactive positions are at: 178, 168, 158, 148
        // The closest inactive to active is 148 to 122, distance = 26
        // Middle would be around 135, with snap threshold of 10, we need > 10 from closest
        final farFromBoth = calculator.determinePositionState(
          BeadType.earthly,
          const Offset(50, 135), // Exactly middle between 122 and 148
        );
        expect(farFromBoth, BeadPosition.moving);
      });
    });

    group('Closest snap position', () {
      test('should find closest snap position for heavenly beads', () {
        // Closer to active
        final closerToActive = calculator.findClosestSnapPosition(BeadType.heavenly, 0, const Offset(50, 60));
        expect(closerToActive, calculator.getHeavenlyActivePosition());

        // Closer to inactive
        final closerToInactive = calculator.findClosestSnapPosition(BeadType.heavenly, 0, const Offset(50, 35));
        expect(closerToInactive, calculator.getHeavenlyInactivePosition());
      });

      test('should find closest snap position for earthly beads', () {
        // Closer to active (for bead index 1)
        final closerToActive = calculator.findClosestSnapPosition(BeadType.earthly, 1, const Offset(50, 105));
        expect(closerToActive, calculator.getEarthlyActivePosition(1));

        // Closer to inactive (for bead index 1)
        final closerToInactive = calculator.findClosestSnapPosition(BeadType.earthly, 1, const Offset(50, 165));
        expect(closerToInactive, calculator.getEarthlyInactivePosition(1));
      });
    });
  });
}
