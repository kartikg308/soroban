// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/bead_model.dart';

/// Widget that displays an individual bead
class BeadWidget extends StatelessWidget {
  final BeadModel bead;
  final double diameter;

  const BeadWidget({super.key, required this.bead, required this.diameter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getBeadColor(),
        border: Border.all(color: _getBorderColor(), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 2, offset: const Offset(1, 1))],
      ),
    );
  }

  /// Gets the color for the bead based on its type and state
  Color _getBeadColor() {
    if (bead.isActive) {
      // Active beads are slightly darker to show they're engaged
      return bead.type == BeadType.heavenly
          ? const Color(0xFF8B4513) // Dark wood brown for heavenly
          : const Color(0xFFA0522D); // Sienna brown for earthly
    } else {
      // Inactive beads are lighter
      return bead.type == BeadType.heavenly
          ? const Color(0xFFCD853F) // Peru brown for heavenly
          : const Color(0xFFDEB887); // Burlywood for earthly
    }
  }

  /// Gets the border color for the bead
  Color _getBorderColor() {
    return const Color(0xFF654321); // Dark brown border
  }
}
