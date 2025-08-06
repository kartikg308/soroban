import 'package:flutter/material.dart';
import '../models/soroban_model.dart';
import 'rod_widget.dart';

/// Main widget that displays the complete soroban abacus
class SorobanWidget extends StatelessWidget {
  final SorobanModel soroban;
  final double? width;
  final double? height;

  const SorobanWidget({super.key, required this.soroban, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = width ?? constraints.maxWidth;
        final availableHeight = height ?? constraints.maxHeight;

        // Calculate responsive dimensions
        final dimensions = _calculateDimensions(availableWidth, availableHeight);

        return Container(
          width: dimensions.sorobanWidth,
          height: dimensions.sorobanHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513), // Traditional wood brown
            border: Border.all(color: const Color(0xFF654321), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Top frame
              Container(height: dimensions.frameHeight, color: const Color(0xFF654321)),
              // Heavenly beads section
              Expanded(flex: 2, child: _buildBeadSection(dimensions, isHeavenly: true)),
              // Reckoning bar
              Container(
                height: dimensions.reckoningBarHeight,
                color: const Color(0xFF654321),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: const Color(0xFF4A4A4A), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Earthly beads section
              Expanded(flex: 3, child: _buildBeadSection(dimensions, isHeavenly: false)),
              // Bottom frame
              Container(height: dimensions.frameHeight, color: const Color(0xFF654321)),
            ],
          ),
        );
      },
    );
  }

  /// Builds the bead section (heavenly or earthly)
  Widget _buildBeadSection(SorobanDimensions dimensions, {required bool isHeavenly}) {
    return Container(
      color: const Color(0xFF8B4513),
      child: Row(
        children: [
          // Left frame
          Container(width: dimensions.frameWidth, color: const Color(0xFF654321)),
          // Rods section
          Expanded(
            child: Row(
              children: soroban.rods.asMap().entries.map((entry) {
                final index = entry.key;
                final rod = entry.value;
                return Expanded(
                  child: RodWidget(rod: rod, dimensions: dimensions, showHeavenlySection: isHeavenly),
                );
              }).toList(),
            ),
          ),
          // Right frame
          Container(width: dimensions.frameWidth, color: const Color(0xFF654321)),
        ],
      ),
    );
  }

  /// Calculates responsive dimensions based on available space
  SorobanDimensions _calculateDimensions(double availableWidth, double availableHeight) {
    // Calculate optimal soroban size maintaining aspect ratio
    final aspectRatio = 2.5; // Width to height ratio for traditional soroban

    double sorobanWidth = availableWidth;
    double sorobanHeight = sorobanWidth / aspectRatio;

    // If height exceeds available space, scale down
    if (sorobanHeight > availableHeight) {
      sorobanHeight = availableHeight;
      sorobanWidth = sorobanHeight * aspectRatio;
    }

    // Ensure minimum size for usability
    const minWidth = 300.0;
    const minHeight = 120.0;

    sorobanWidth = sorobanWidth.clamp(minWidth, double.infinity);
    sorobanHeight = sorobanHeight.clamp(minHeight, double.infinity);

    // Calculate component dimensions
    final frameWidth = sorobanWidth * 0.03;
    final frameHeight = sorobanHeight * 0.05;
    final reckoningBarHeight = sorobanHeight * 0.04;
    final rodWidth = (sorobanWidth - (frameWidth * 2)) / soroban.numberOfRods;
    final beadDiameter = (rodWidth * 0.7).clamp(8.0, 24.0);

    return SorobanDimensions(sorobanWidth: sorobanWidth, sorobanHeight: sorobanHeight, frameWidth: frameWidth, frameHeight: frameHeight, reckoningBarHeight: reckoningBarHeight, rodWidth: rodWidth, beadDiameter: beadDiameter);
  }
}

/// Data class holding calculated dimensions for the soroban
class SorobanDimensions {
  final double sorobanWidth;
  final double sorobanHeight;
  final double frameWidth;
  final double frameHeight;
  final double reckoningBarHeight;
  final double rodWidth;
  final double beadDiameter;

  const SorobanDimensions({required this.sorobanWidth, required this.sorobanHeight, required this.frameWidth, required this.frameHeight, required this.reckoningBarHeight, required this.rodWidth, required this.beadDiameter});
}
