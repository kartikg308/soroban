import 'package:flutter_test/flutter_test.dart';
import 'package:soroban/models/models.dart';

void main() {
  group('BeadModel', () {
    test('should create a heavenly bead with correct properties', () {
      final bead = BeadModel(type: BeadType.heavenly, value: 5);

      expect(bead.type, BeadType.heavenly);
      expect(bead.value, 5);
      expect(bead.position, BeadPosition.inactive);
      expect(bead.currentOffset, Offset.zero);
      expect(bead.isActive, false);
      expect(bead.isMoving, false);
    });

    test('should create an earthly bead with correct properties', () {
      final bead = BeadModel(type: BeadType.earthly, value: 1);

      expect(bead.type, BeadType.earthly);
      expect(bead.value, 1);
      expect(bead.position, BeadPosition.inactive);
      expect(bead.currentOffset, Offset.zero);
      expect(bead.isActive, false);
      expect(bead.isMoving, false);
    });

    test('should create a bead with custom position and offset', () {
      const customOffset = Offset(10, 20);
      final bead = BeadModel(type: BeadType.heavenly, value: 5, position: BeadPosition.active, currentOffset: customOffset);

      expect(bead.position, BeadPosition.active);
      expect(bead.currentOffset, customOffset);
      expect(bead.isActive, true);
      expect(bead.isMoving, false);
    });

    test('should update position correctly', () {
      final bead = BeadModel(type: BeadType.earthly, value: 1);

      expect(bead.position, BeadPosition.inactive);
      expect(bead.isActive, false);

      bead.setPosition(BeadPosition.active);
      expect(bead.position, BeadPosition.active);
      expect(bead.isActive, true);

      bead.setPosition(BeadPosition.moving);
      expect(bead.position, BeadPosition.moving);
      expect(bead.isMoving, true);
    });

    test('should update offset correctly', () {
      final bead = BeadModel(type: BeadType.earthly, value: 1);

      expect(bead.currentOffset, Offset.zero);

      const newOffset = Offset(15, 25);
      bead.updateOffset(newOffset);
      expect(bead.currentOffset, newOffset);
    });

    test('should handle animation controller correctly', () {
      final bead = BeadModel(type: BeadType.earthly, value: 1);

      expect(bead.animationController, null);

      // Note: We can't create a real AnimationController in unit tests
      // without a TickerProvider, so we'll just test the setter/getter
      bead.setAnimationController(null);
      expect(bead.animationController, null);
    });

    test('should create correct copy with copyWith', () {
      final original = BeadModel(type: BeadType.heavenly, value: 5, position: BeadPosition.active, currentOffset: const Offset(10, 20));

      final copy = original.copyWith(position: BeadPosition.moving, currentOffset: const Offset(30, 40));

      expect(copy.type, BeadType.heavenly);
      expect(copy.value, 5);
      expect(copy.position, BeadPosition.moving);
      expect(copy.currentOffset, const Offset(30, 40));

      // Original should be unchanged
      expect(original.position, BeadPosition.active);
      expect(original.currentOffset, const Offset(10, 20));
    });

    test('should implement equality correctly', () {
      final bead1 = BeadModel(type: BeadType.heavenly, value: 5, position: BeadPosition.active, currentOffset: const Offset(10, 20));

      final bead2 = BeadModel(type: BeadType.heavenly, value: 5, position: BeadPosition.active, currentOffset: const Offset(10, 20));

      final bead3 = BeadModel(type: BeadType.earthly, value: 1, position: BeadPosition.active, currentOffset: const Offset(10, 20));

      expect(bead1, equals(bead2));
      expect(bead1, isNot(equals(bead3)));
      expect(bead1.hashCode, equals(bead2.hashCode));
    });

    test('should have meaningful toString representation', () {
      final bead = BeadModel(type: BeadType.heavenly, value: 5, position: BeadPosition.active, currentOffset: const Offset(10, 20));

      final string = bead.toString();
      expect(string, contains('BeadModel'));
      expect(string, contains('heavenly'));
      expect(string, contains('5'));
      expect(string, contains('active'));
      expect(string, contains('10'));
      expect(string, contains('20'));
    });

    test('should dispose resources correctly', () {
      final bead = BeadModel(type: BeadType.earthly, value: 1);

      // Test that dispose doesn't throw when no animation controller is set
      expect(() => bead.dispose(), returnsNormally);
    });
  });

  group('BeadModel State Transitions', () {
    test('should allow valid state transitions', () {
      final bead = BeadModel(type: BeadType.earthly, value: 1);

      // From inactive to moving
      expect(bead.canTransitionTo(BeadPosition.moving), true);
      bead.setPosition(BeadPosition.moving);
      expect(bead.position, BeadPosition.moving);

      // From moving to active
      expect(bead.canTransitionTo(BeadPosition.active), true);
      bead.setPosition(BeadPosition.active);
      expect(bead.position, BeadPosition.active);

      // From active to moving
      expect(bead.canTransitionTo(BeadPosition.moving), true);
      bead.setPosition(BeadPosition.moving);
      expect(bead.position, BeadPosition.moving);

      // From moving to inactive
      expect(bead.canTransitionTo(BeadPosition.inactive), true);
      bead.setPosition(BeadPosition.inactive);
      expect(bead.position, BeadPosition.inactive);
    });

    test('should allow direct transitions between active and inactive', () {
      final bead = BeadModel(type: BeadType.earthly, value: 1);

      // From inactive to active
      expect(bead.canTransitionTo(BeadPosition.active), true);
      bead.setPosition(BeadPosition.active);
      expect(bead.position, BeadPosition.active);

      // From active to inactive
      expect(bead.canTransitionTo(BeadPosition.inactive), true);
      bead.setPosition(BeadPosition.inactive);
      expect(bead.position, BeadPosition.inactive);
    });

    test('should allow same state transitions', () {
      final bead = BeadModel(type: BeadType.earthly, value: 1);

      // Same state should always be valid
      expect(bead.canTransitionTo(BeadPosition.inactive), true);
      bead.setPosition(BeadPosition.inactive);
      expect(bead.position, BeadPosition.inactive);
    });

    test('should validate all transition combinations', () {
      final bead = BeadModel(type: BeadType.earthly, value: 1);

      // Test all valid transitions from each state
      final validTransitions = {
        BeadPosition.inactive: [BeadPosition.inactive, BeadPosition.moving, BeadPosition.active],
        BeadPosition.active: [BeadPosition.active, BeadPosition.moving, BeadPosition.inactive],
        BeadPosition.moving: [BeadPosition.moving, BeadPosition.active, BeadPosition.inactive],
      };

      for (final fromState in BeadPosition.values) {
        bead.setPosition(fromState);
        for (final toState in BeadPosition.values) {
          final shouldBeValid = validTransitions[fromState]!.contains(toState);
          expect(bead.canTransitionTo(toState), shouldBeValid, reason: 'Transition from $fromState to $toState should be ${shouldBeValid ? 'valid' : 'invalid'}');
        }
      }
    });
  });

  group('InvalidBeadTransitionException', () {
    test('should have correct properties', () {
      const exception = InvalidBeadTransitionException('Test message', BeadPosition.inactive, BeadPosition.moving);

      expect(exception.message, 'Test message');
      expect(exception.fromState, BeadPosition.inactive);
      expect(exception.toState, BeadPosition.moving);
    });

    test('should have meaningful toString', () {
      const exception = InvalidBeadTransitionException('Test message', BeadPosition.inactive, BeadPosition.moving);

      final string = exception.toString();
      expect(string, contains('InvalidBeadTransitionException'));
      expect(string, contains('Test message'));
      expect(string, contains('inactive'));
      expect(string, contains('moving'));
    });
  });

  group('BeadType enum', () {
    test('should have correct values', () {
      expect(BeadType.values.length, 2);
      expect(BeadType.values, contains(BeadType.heavenly));
      expect(BeadType.values, contains(BeadType.earthly));
    });
  });

  group('BeadPosition enum', () {
    test('should have correct values', () {
      expect(BeadPosition.values.length, 3);
      expect(BeadPosition.values, contains(BeadPosition.active));
      expect(BeadPosition.values, contains(BeadPosition.inactive));
      expect(BeadPosition.values, contains(BeadPosition.moving));
    });
  });
}
