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

    // Position based on bead state
    final double topPosition = bead.isActive
        ? 8 // Active position (near reckoning bar)
        : 40; // Inactive position (away from reckoning bar)

    return Positioned(
      left: (widget.dimensions.rodWidth - widget.dimensions.beadDiameter) / 2,
      top: topPosition,
      child: Draggable<BeadModel>(
        data: bead,
        feedback: BeadWidget(bead: bead, diameter: widget.dimensions.beadDiameter),
        childWhenDragging: Container(
          width: widget.dimensions.beadDiameter,
          height: widget.dimensions.beadDiameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(0.3),
            border: Border.all(color: const Color(0xFF654321), width: 1),
          ),
        ),
        child: GestureDetector(
          onPanUpdate: (details) => _handleHeavenlyBeadDrag(details),
          onPanEnd: (details) => _handleHeavenlyBeadDragEnd(details),
          child: BeadWidget(bead: bead, diameter: widget.dimensions.beadDiameter),
        ),
      ),
    );
  }

  /// Builds the earthly beads (ichi-dama) for this rod
  Widget _buildEarthlyBeads() {
    return Stack(
      children: [
        // Position each bead individually based on its state
        ...widget.rod.earthlyBeads.asMap().entries.map((entry) {
          final index = entry.key;
          final bead = entry.value;
          return _positionEarthlyBead(bead, index);
        }),
      ],
    );
  }

  /// Positions an individual earthly bead based on its state
  Widget _positionEarthlyBead(BeadModel bead, int index) {
    double topPosition;

    if (bead.isActive) {
      // Active beads move up to the reckoning bar area (top of earthly section)
      final activeBeads = widget.rod.earthlyBeads.where((b) => b.isActive).toList();
      final activeIndex = activeBeads.indexOf(bead);
      topPosition = 8 + (activeIndex * (widget.dimensions.beadDiameter + 2));
    } else {
      // Inactive beads stay at the bottom
      final inactiveBeads = widget.rod.earthlyBeads.where((b) => !b.isActive).toList();
      final inactiveIndex = inactiveBeads.indexOf(bead);
      // Calculate from bottom of container
      final containerHeight = 200.0; // Approximate earthly section height
      topPosition = containerHeight - 8 - widget.dimensions.beadDiameter - (inactiveIndex * (widget.dimensions.beadDiameter + 2));
    }

    return Positioned(
      left: (widget.dimensions.rodWidth - widget.dimensions.beadDiameter) / 2,
      top: topPosition,
      child: Draggable<BeadModel>(
        data: bead,
        feedback: BeadWidget(bead: bead, diameter: widget.dimensions.beadDiameter),
        childWhenDragging: Container(
          width: widget.dimensions.beadDiameter,
          height: widget.dimensions.beadDiameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(0.3),
            border: Border.all(color: const Color(0xFF654321), width: 1),
          ),
        ),
        child: GestureDetector(
          onPanUpdate: (details) => _handleEarthlyBeadDrag(bead, details),
          onPanEnd: (details) => _handleEarthlyBeadDragEnd(bead, details),
          child: BeadWidget(bead: bead, diameter: widget.dimensions.beadDiameter),
        ),
      ),
    );
  }

  /// Handles dragging of heavenly bead
  void _handleHeavenlyBeadDrag(DragUpdateDetails details) {
    // Set bead to moving state during drag
    if (widget.rod.heavenlyBead.position != BeadPosition.moving) {
      setState(() {
        widget.rod.heavenlyBead.setPosition(BeadPosition.moving);
      });
    }
  }

  /// Handles end of heavenly bead drag
  void _handleHeavenlyBeadDragEnd(DragEndDetails details) {
    setState(() {
      // Determine final position based on drag direction/velocity
      final velocity = details.velocity.pixelsPerSecond.dy;

      if (velocity < -50) {
        // Dragged up quickly - make active
        widget.rod.heavenlyBead.setPosition(BeadPosition.active);
      } else if (velocity > 50) {
        // Dragged down quickly - make inactive
        widget.rod.heavenlyBead.setPosition(BeadPosition.inactive);
      } else {
        // Slow drag - toggle state
        if (widget.rod.heavenlyBead.isActive) {
          widget.rod.heavenlyBead.setPosition(BeadPosition.inactive);
        } else {
          widget.rod.heavenlyBead.setPosition(BeadPosition.active);
        }
      }
    });
  }

  /// Handles dragging of earthly bead
  void _handleEarthlyBeadDrag(BeadModel bead, DragUpdateDetails details) {
    // Set bead to moving state during drag
    if (bead.position != BeadPosition.moving) {
      setState(() {
        bead.setPosition(BeadPosition.moving);
      });
    }
  }

  /// Handles end of earthly bead drag
  void _handleEarthlyBeadDragEnd(BeadModel bead, DragEndDetails details) {
    setState(() {
      // Determine final position based on drag direction/velocity
      final velocity = details.velocity.pixelsPerSecond.dy;

      if (velocity < -50) {
        // Dragged up quickly - make active
        bead.setPosition(BeadPosition.active);
      } else if (velocity > 50) {
        // Dragged down quickly - make inactive
        bead.setPosition(BeadPosition.inactive);
      } else {
        // Slow drag - toggle state
        if (bead.isActive) {
          bead.setPosition(BeadPosition.inactive);
        } else {
          bead.setPosition(BeadPosition.active);
        }
      }
    });
  }

  /// Toggles the state of a bead between active and inactive
  void _toggleBeadState(BeadModel bead) {
    setState(() {
      if (bead.isActive) {
        bead.setPosition(BeadPosition.inactive);
      } else {
        bead.setPosition(BeadPosition.active);
      }
    });
  }

  /// Toggles the heavenly bead state
  void _toggleHeavenlyBeadState() {
    setState(() {
      if (widget.rod.heavenlyBead.isActive) {
        widget.rod.heavenlyBead.setPosition(BeadPosition.inactive);
      } else {
        widget.rod.heavenlyBead.setPosition(BeadPosition.active);
      }
    });
  }
}
