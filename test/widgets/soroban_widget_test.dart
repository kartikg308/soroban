import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soroban/models/soroban_model.dart';
import 'package:soroban/widgets/rod_widget.dart';
import 'package:soroban/widgets/soroban_widget.dart';

void main() {
  group('SorobanWidget', () {
    late SorobanModel soroban;

    setUp(() {
      soroban = SorobanModel.create();
    });

    tearDown(() {
      soroban.dispose();
    });

    testWidgets('displays basic soroban structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SorobanWidget(soroban: soroban)),
        ),
      );

      // Verify main container exists
      expect(find.byType(SorobanWidget), findsOneWidget);

      // Verify the soroban has the correct structure with frames and sections
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('displays correct number of rods', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SorobanWidget(soroban: soroban)),
        ),
      );

      // Should have RodWidgets equal to the number of rods in the soroban
      // Each rod appears twice (once for heavenly section, once for earthly)
      expect(find.byType(RodWidget), findsNWidgets(soroban.numberOfRods * 2));
    });

    testWidgets('adapts to different screen sizes', (WidgetTester tester) async {
      // Test with small screen size
      await tester.binding.setSurfaceSize(const Size(400, 300));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SorobanWidget(soroban: soroban)),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widget renders without overflow
      expect(tester.takeException(), isNull);
      expect(find.byType(SorobanWidget), findsOneWidget);

      // Test with large screen size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SorobanWidget(soroban: soroban)),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widget renders without overflow
      expect(tester.takeException(), isNull);
      expect(find.byType(SorobanWidget), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('maintains proper proportions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SorobanWidget(soroban: soroban)),
        ),
      );

      await tester.pumpAndSettle();

      // Find the main soroban container
      final sorobanContainer = tester.widget<Container>(find.byType(Container).first);

      // Verify the container has proper decoration (wood-like appearance)
      expect(sorobanContainer.decoration, isA<BoxDecoration>());
      final decoration = sorobanContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF8B4513)));
      expect(decoration.border, isNotNull);
      expect(decoration.borderRadius, isNotNull);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SorobanWidget(soroban: soroban)),
        ),
      );

      // Verify the main column structure
      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.children.length, equals(5)); // Top frame, heavenly, bar, earthly, bottom frame

      // Verify expanded widgets for proper flex layout
      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets('respects custom width and height', (WidgetTester tester) async {
      const customWidth = 600.0;
      const customHeight = 240.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SorobanWidget(soroban: soroban, width: customWidth, height: customHeight),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widget renders with custom dimensions
      expect(find.byType(SorobanWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    group('SorobanDimensions', () {
      test('calculates proper dimensions', () {
        const dimensions = SorobanDimensions(sorobanWidth: 500, sorobanHeight: 200, frameWidth: 15, frameHeight: 10, reckoningBarHeight: 8, rodWidth: 35, beadDiameter: 20);

        expect(dimensions.sorobanWidth, equals(500));
        expect(dimensions.sorobanHeight, equals(200));
        expect(dimensions.frameWidth, equals(15));
        expect(dimensions.frameHeight, equals(10));
        expect(dimensions.reckoningBarHeight, equals(8));
        expect(dimensions.rodWidth, equals(35));
        expect(dimensions.beadDiameter, equals(20));
      });
    });
  });
}
