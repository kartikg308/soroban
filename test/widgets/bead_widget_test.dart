import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soroban/models/bead_model.dart';
import 'package:soroban/widgets/bead_widget.dart';

void main() {
  group('BeadWidget', () {
    late BeadModel heavenlyBead;
    late BeadModel earthlyBead;
    const testDiameter = 20.0;

    setUp(() {
      heavenlyBead = BeadModel(type: BeadType.heavenly, value: 5);
      earthlyBead = BeadModel(type: BeadType.earthly, value: 1);
    });

    tearDown() {
      heavenlyBead.dispose();
      earthlyBead.dispose();
    }

    testWidgets('displays bead with correct size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeadWidget(bead: heavenlyBead, diameter: testDiameter),
          ),
        ),
      );

      // Find the bead container and verify its size
      final containerFinder = find.byType(Container).first;
      final containerSize = tester.getSize(containerFinder);
      expect(containerSize.width, equals(testDiameter));
      expect(containerSize.height, equals(testDiameter));
    });

    testWidgets('displays circular shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeadWidget(bead: heavenlyBead, diameter: testDiameter),
          ),
        ),
      );

      // Verify circular decoration
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('shows different colors for heavenly vs earthly beads', (WidgetTester tester) async {
      // Test heavenly bead
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeadWidget(bead: heavenlyBead, diameter: testDiameter),
          ),
        ),
      );

      final heavenlyContainer = tester.widget<Container>(find.byType(Container).first);
      final heavenlyDecoration = heavenlyContainer.decoration as BoxDecoration;
      final heavenlyColor = heavenlyDecoration.color;

      // Test earthly bead
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeadWidget(bead: earthlyBead, diameter: testDiameter),
          ),
        ),
      );

      final earthlyContainer = tester.widget<Container>(find.byType(Container).first);
      final earthlyDecoration = earthlyContainer.decoration as BoxDecoration;
      final earthlyColor = earthlyDecoration.color;

      // Colors should be different
      expect(heavenlyColor, isNot(equals(earthlyColor)));
    });

    testWidgets('shows different colors for active vs inactive beads', (WidgetTester tester) async {
      // Test inactive bead
      final inactiveBead = BeadModel(type: BeadType.heavenly, value: 5, position: BeadPosition.inactive);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeadWidget(bead: inactiveBead, diameter: testDiameter),
          ),
        ),
      );

      final inactiveContainer = tester.widget<Container>(find.byType(Container).first);
      final inactiveDecoration = inactiveContainer.decoration as BoxDecoration;
      final inactiveColor = inactiveDecoration.color;

      // Test active bead
      final activeBead = BeadModel(type: BeadType.heavenly, value: 5, position: BeadPosition.active);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeadWidget(bead: activeBead, diameter: testDiameter),
          ),
        ),
      );

      final activeContainer = tester.widget<Container>(find.byType(Container).first);
      final activeDecoration = activeContainer.decoration as BoxDecoration;
      final activeColor = activeDecoration.color;

      // Colors should be different
      expect(inactiveColor, isNot(equals(activeColor)));

      // Clean up
      inactiveBead.dispose();
      activeBead.dispose();
    });

    testWidgets('has border and shadow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeadWidget(bead: heavenlyBead, diameter: testDiameter),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      // Verify border
      expect(decoration.border, isNotNull);
      expect(decoration.border, isA<Border>());

      // Verify shadow
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThan(0));
    });

    testWidgets('renders without errors for different bead types', (WidgetTester tester) async {
      // Test heavenly bead
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeadWidget(bead: heavenlyBead, diameter: testDiameter),
          ),
        ),
      );

      expect(find.byType(BeadWidget), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Test earthly bead
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeadWidget(bead: earthlyBead, diameter: testDiameter),
          ),
        ),
      );

      expect(find.byType(BeadWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adapts to different diameters', (WidgetTester tester) async {
      const smallDiameter = 10.0;
      const largeDiameter = 30.0;

      // Test small diameter
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeadWidget(bead: heavenlyBead, diameter: smallDiameter),
          ),
        ),
      );

      final smallContainerSize = tester.getSize(find.byType(Container).first);
      expect(smallContainerSize.width, equals(smallDiameter));

      // Test large diameter
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeadWidget(bead: heavenlyBead, diameter: largeDiameter),
          ),
        ),
      );

      final largeContainerSize = tester.getSize(find.byType(Container).first);
      expect(largeContainerSize.width, equals(largeDiameter));
    });
  });
}
