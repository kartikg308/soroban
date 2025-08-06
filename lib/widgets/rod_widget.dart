import 'package:flutter/material.dart';
import '../models/rod_model.dart';
import '../models/bead_model.dart';
import 'soroban_widget.dart';
import 'bead_widget.dart';

/// Widget that displays a single rod with its beads
class RodWidget extends StatefulWidget {
  final RodModel rod;
  final SorobanDimensions dimensions;
  final bool showHeavenlySection;

  const RodWidget({super.key, required this.rod, required this.dimensions, required this.showHeavenlySection});

  @override
  State<RodWidget> createState() => _RodWidgetState();
}

class _RodWidgetState extends State<RodWidget> {
  // Track individual bead positions for earthly beads
  final Map<int, double> _beadPositions = {};
  // Track heavenly bead position
  double _heavenlyBeadPosition = 8.0; // Default inactive position
  final double _minBeadPosition = 8.0; // Top position (near reckoning bar)
  final double _maxBeadPosition = 160.0; // Bottom position
  final double _beadSpacing = 4.0; // Spacing between beads
  final double _heavenlyMinPosition = 8.0; // Heavenly bead top position
  final double _heavenlyMaxPosition = 80.0; // Heavenly bead bottom position

  @override
  void initState() {
    super.initState();
    // Initialize bead positions in stacked formation
    _initializeBeadPositions();
  }

  /// Initialize bead positions in a stacked formation
  void _initializeBeadPositions() {
    for (int i = 0; i < widget.rod.earthlyBeads.length; i++) {
      _beadPositions[i] = _maxBeadPosition - (i * (widget.dimensions.beadDiameter + _beadSpacing));
    }
    // Initialize heavenly bead position
    _heavenlyBeadPosition = _heavenlyMinPosition;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.dimensions.rodWidth,
      child: Stack(
        children: [
          // Rod line (vertical line through the center)
          Positioned(
            left: widget.dimensions.rodWidth / 2 - 1,
            top: 0,
            bottom: 0,
            child: SizedBox(width: 2, child: Container(color: const Color(0xFF654321))),
          ),
          // Unit rod marker (dot) - only show in earthly section for unit rods
          if (widget.rod.isUnitRod && !widget.showHeavenlySection)
            Positioned(
              left: widget.dimensions.rodWidth / 2 - 3,
              bottom: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Color(0xFF654321), shape: BoxShape.circle),
              ),
            ),
          // Beads
          if (widget.showHeavenlySection) _buildHeavenlyBead() else _buildEarthlyBeads(),
        ],
      ),
    );
  }

  /// Builds the heavenly bead (go-dama) for this rod
  Widget _buildHeavenlyBead() {
    final bead = widget.rod.heavenlyBead;

    return Positioned(
      left: (widget.dimensions.rodWidth - widget.dimensions.beadDiameter) / 2,
      top: _heavenlyBeadPosition,
      child: GestureDetector(
        onVerticalDragUpdate: (details) => _handleHeavenlyBeadDrag(details),
        onVerticalDragEnd: (details) => _handleHeavenlyBeadDragEnd(details),
        child: BeadWidget(bead: bead, diameter: widget.dimensions.beadDiameter),
      ),
    );
  }

  /// Handles vertical dragging of heavenly bead
  void _handleHeavenlyBeadDrag(DragUpdateDetails details) {
    setState(() {
      final newPosition = _heavenlyBeadPosition + details.delta.dy;

      // Constrain position within heavenly bead bounds
      final constrainedPosition = newPosition.clamp(_heavenlyMinPosition, _heavenlyMaxPosition);
      _heavenlyBeadPosition = constrainedPosition;

      // Update bead state based on position
      final bead = widget.rod.heavenlyBead;
      // Active when moved down (towards max position)
      if (constrainedPosition >= _heavenlyMaxPosition - 10) {
        // Near bottom (reckoning bar) - consider active
        if (!bead.isActive) {
          bead.setPosition(BeadPosition.active);
        }
      } else {
        // Away from bottom - consider inactive
        if (bead.isActive) {
          bead.setPosition(BeadPosition.inactive);
        }
      }
    });
  }

  /// Handles end of heavenly bead drag
  void _handleHeavenlyBeadDragEnd(DragEndDetails details) {
    setState(() {
      // Determine final position based on whether it's closer to the top or bottom
      final middle = (_heavenlyMinPosition + _heavenlyMaxPosition) / 2;
      if (_heavenlyBeadPosition > middle) {
        // Snap to bottom (active position)
        _heavenlyBeadPosition = _heavenlyMaxPosition;
        widget.rod.heavenlyBead.setPosition(BeadPosition.active);
      } else {
        // Snap to top (inactive position)
        _heavenlyBeadPosition = _heavenlyMinPosition;
        widget.rod.heavenlyBead.setPosition(BeadPosition.inactive);
      }
    });
  }

  /// Builds the earthly beads (ichi-dama) for this rod
  Widget _buildEarthlyBeads() {
    return Stack(
      children: [
        // Position each of the 4 earthly beads individually with drag capability
        ...widget.rod.earthlyBeads.asMap().entries.map((entry) {
          final index = entry.key;
          final bead = entry.value;
          return _positionEarthlyBead(bead, index);
        }),
      ],
    );
  }

  /// Positions an individual earthly bead with vertical drag capability
  Widget _positionEarthlyBead(BeadModel bead, int index) {
    final currentPosition = _beadPositions[index] ?? _maxBeadPosition;

    return Positioned(
      left: (widget.dimensions.rodWidth - widget.dimensions.beadDiameter) / 2,
      top: currentPosition,
      child: GestureDetector(
        onVerticalDragUpdate: (details) => _handleEarthlyBeadDrag(index, details),
        onVerticalDragEnd: (details) => _handleEarthlyBeadDragEnd(bead, index, details),
        child: BeadWidget(bead: bead, diameter: widget.dimensions.beadDiameter),
      ),
    );
  }

  /// Handles vertical dragging of earthly beads
  void _handleEarthlyBeadDrag(int beadIndex, DragUpdateDetails details) {
    setState(() {
      final currentPosition = _beadPositions[beadIndex] ?? _maxBeadPosition;
      final newPosition = currentPosition + details.delta.dy;

      // Constrain position within bounds
      final constrainedPosition = newPosition.clamp(_minBeadPosition, _maxBeadPosition);

      // Check for collisions with other beads
      final collisionFreePosition = _resolveCollisions(beadIndex, constrainedPosition);
      _beadPositions[beadIndex] = collisionFreePosition;

      // Update bead state based on position
      final bead = widget.rod.earthlyBeads[beadIndex];
      if (collisionFreePosition <= _minBeadPosition + 10) {
        // Near top - consider active
        if (!bead.isActive) {
          bead.setPosition(BeadPosition.active);
        }
      } else {
        // Away from top - consider inactive
        if (bead.isActive) {
          bead.setPosition(BeadPosition.inactive);
        }
      }
    });
  }

  /// Resolves collisions between beads to prevent overlapping
  double _resolveCollisions(int movingBeadIndex, double targetPosition) {
    final beadHeight = widget.dimensions.beadDiameter;
    final minSpacing = _beadSpacing;

    // Check collision with each other bead
    for (int i = 0; i < widget.rod.earthlyBeads.length; i++) {
      if (i == movingBeadIndex) continue;

      final otherPosition = _beadPositions[i] ?? _maxBeadPosition;
      final distance = (targetPosition - otherPosition).abs();

      // If beads would overlap, adjust the moving bead's position
      if (distance < beadHeight + minSpacing) {
        if (targetPosition > otherPosition) {
          // Moving bead is below the other bead, push it down
          targetPosition = otherPosition + beadHeight + minSpacing;
        } else {
          // Moving bead is above the other bead, push it up
          targetPosition = otherPosition - beadHeight - minSpacing;
        }
      }
    }

    // Ensure the adjusted position is still within bounds
    return targetPosition.clamp(_minBeadPosition, _maxBeadPosition);
  }

  /// Handles end of earthly bead drag
  void _handleEarthlyBeadDragEnd(BeadModel bead, int beadIndex, DragEndDetails details) {
    setState(() {
      final currentPosition = _beadPositions[beadIndex] ?? _maxBeadPosition;

      // Determine final position based on current position
      if (currentPosition <= _minBeadPosition + 20) {
        // Keep the exact position where the bead was dragged to (near top)
        // Don't snap to a fixed position - maintain the individual offset
        _beadPositions[beadIndex] = currentPosition;
        bead.setPosition(BeadPosition.active);
      } else {
        // Snap to bottom (inactive position) - maintain stacked order
        // _snapToStackedPosition(beadIndex);
        bead.setPosition(BeadPosition.inactive);
      }
    });
  }

  /// Snaps a bead to its proper position in the stacked formation
  void _snapToStackedPosition(int beadIndex) {
    // Find the proper position in the stacked formation
    final stackedPosition = _maxBeadPosition - (beadIndex * (widget.dimensions.beadDiameter + _beadSpacing));
    _beadPositions[beadIndex] = stackedPosition;
  }
}
