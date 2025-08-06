import 'package:flutter/material.dart';
import '../models/rod_model.dart';
import 'soroban_widget.dart';
import 'bead_widget.dart';

/// Widget that displays a single rod with its beads
class RodWidget extends StatelessWidget {
  final RodModel rod;
  final SorobanDimensions dimensions;
  final bool showHeavenlySection;

  const RodWidget({super.key, required this.rod, required this.dimensions, required this.showHeavenlySection});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: dimensions.rodWidth,
      child: Stack(
        children: [
          // Rod line (vertical line through the center)
          Positioned(
            left: dimensions.rodWidth / 2 - 1,
            top: 0,
            bottom: 0,
            child: SizedBox(width: 2, child: Container(color: const Color(0xFF654321))),
          ),
          // Unit rod marker (dot) - only show in earthly section for unit rods
          if (rod.isUnitRod && !showHeavenlySection)
            Positioned(
              left: dimensions.rodWidth / 2 - 3,
              bottom: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Color(0xFF654321), shape: BoxShape.circle),
              ),
            ),
          // Beads
          if (showHeavenlySection) _buildHeavenlyBead() else _buildEarthlyBeads(),
        ],
      ),
    );
  }

  /// Builds the heavenly bead (go-dama) for this rod
  Widget _buildHeavenlyBead() {
    return Positioned(
      left: (dimensions.rodWidth - dimensions.beadDiameter) / 2,
      top: 8,
      child: BeadWidget(bead: rod.heavenlyBead, diameter: dimensions.beadDiameter),
    );
  }

  /// Builds the earthly beads (ichi-dama) for this rod
  Widget _buildEarthlyBeads() {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 4),
          ...rod.earthlyBeads.map((bead) {
            return Flexible(
              child: Center(
                child: BeadWidget(bead: bead, diameter: dimensions.beadDiameter),
              ),
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
