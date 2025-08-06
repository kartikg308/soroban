import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soroban/models/rod_model.dart';
import 'package:soroban/widgets/bead_widget.dart';
import 'package:soroban/widgets/rod_widget.dart';
import 'package:soroban/widgets/soroban_widget.dart';

void main() {
  group('RodWidget', () {
    late RodModel regularRod;
    late RodModel unitRod;
    late SorobanDimensions dimensions;

    setUp(() {
      regularRod = RodModel.create(index: 0, isUnitRod: false);
      unitRod = RodModel.create(index: 2, isUnitRod: true);
      dimensions = const SorobanDimensions(sorobanWidth: 500, sorobanHeight: 200, frameWidth: 15, frameHeight: 10, reckoningBarHeight: 8, rodWidth: 35, beadDiameter: 20);
    });

    tearDown(() {
      regularRod.dispose();
      unitRod.dispose();
    });

    testWidgets('displays heavenly bead in heavenly section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RodWidget(rod: regularRod, dimensions: dimensions, showHeavenlySection: true),
          ),
        ),
      );

      // Should show one bead (the heavenly bead)
      expect(find.byType(BeadWidget), findsOneWidget);

      // Verify the rod line is present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays earthly beads in earthly section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RodWidget(rod: regularRod, dimensions: dimensions, showHeavenlySection: false),
          ),
        ),
      );

      // Should show four beads (the earthly beads)
      expect(find.byType(BeadWidget), findsNWidgets(4));

      // Verify column layout for earthly beads
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('shows unit rod marker for unit rods in earthly section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RodWidget(rod: unitRod, dimensions: dimensions, showHeavenlySection: false),
          ),
        ),
      );

      // Find containers (including the unit marker)
      final containers = find.byType(Container);
      expect(containers, findsWidgets);

      // Verify that there are containers with circular decoration (unit marker)
      bool foundCircularMarker = false;
      for (int i = 0; i < tester.widgetList(containers).length; i++) {
        final container = tester.widget<Container>(containers.at(i));
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.shape == BoxShape.circle) {
            foundCircularMarker = true;
            break;
          }
        }
      }
      expect(foundCircularMarker, isTrue);
    });

    testWidgets('does not show unit rod marker for regular rods', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RodWidget(rod: regularRod, dimensions: dimensions, showHeavenlySection: false),
          ),
        ),
      );

      // Find containers
      final containers = find.byType(Container);
      expect(containers, findsWidgets);

      // Verify that there are no containers with circular decoration (unit marker)
      bool foundCircularMarker = false;
      for (int i = 0; i < tester.widgetList(containers).length; i++) {
        final container = tester.widget<Container>(containers.at(i));
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.shape == BoxShape.circle) {
            foundCircularMarker = true;
            break;
          }
        }
      }
      expect(foundCircularMarker, isFalse);
    });

    testWidgets('does not show unit rod marker in heavenly section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RodWidget(rod: unitRod, dimensions: dimensions, showHeavenlySection: true),
          ),
        ),
      );

      // Find containers
      final containers = find.byType(Container);
      expect(containers, findsWidgets);

      // Verify that there are no containers with circular decoration (unit marker)
      bool foundCircularMarker = false;
      for (int i = 0; i < tester.widgetList(containers).length; i++) {
        final container = tester.widget<Container>(containers.at(i));
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.shape == BoxShape.circle) {
            foundCircularMarker = true;
            break;
          }
        }
      }
      expect(foundCircularMarker, isFalse);
    });

    testWidgets('has proper rod structure with vertical line', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RodWidget(rod: regularRod, dimensions: dimensions, showHeavenlySection: true),
          ),
        ),
      );

      // Verify stack layout
      expect(find.byType(Stack), findsOneWidget);

      // Verify positioned widgets (rod line and beads)
      expect(find.byType(Positioned), findsWidgets);
    });

    testWidgets('respects dimensions for rod width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RodWidget(rod: regularRod, dimensions: dimensions, showHeavenlySection: true),
          ),
        ),
      );

      // Find the main container and verify its width
      final mainContainerSize = tester.getSize(find.byType(Container).first);
      expect(mainContainerSize.width, equals(dimensions.rodWidth));
    });

    testWidgets('positions beads correctly in earthly section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RodWidget(rod: regularRod, dimensions: dimensions, showHeavenlySection: false),
          ),
        ),
      );

      // Verify column structure for earthly beads
      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.children.length, equals(5)); // SizedBox + 4 beads

      // Verify padding between beads
      expect(find.byType(Padding), findsWidgets);
    });
  });
}
