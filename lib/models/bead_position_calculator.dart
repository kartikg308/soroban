import 'package:flutter/material.dart';
import 'bead_model.dart';

/// Configuration for rod dimensions and positioning
class RodDimensions {
  final double width;
  final double height;
  final double reckoningBarY; // Y position of the reckoning bar
  final double heavenlyBeadRadius;
  final double earthlyBeadRadius;
  final double beadSpacing; // Minimum spacing between beads

  const RodDimensions({required this.width, required this.height, required this.reckoningBarY, required this.heavenlyBeadRadius, required this.earthlyBeadRadius, required this.beadSpacing});

  /// Gets the heavenly bead section height (above reckoning bar)
  double get heavenlySection => reckoningBarY;

  /// Gets the earthly bead section height (below reckoning bar)
  double get earthlySection => height - reckoningBarY;
}

/// Utility class for calculating bead positions within rod boundaries
class BeadPositionCalculator {
  final RodDimensions dimensions;

  const BeadPositionCalculator(this.dimensions);

  /// Calculates the active position for a heavenly bead (against reckoning bar)
  Offset getHeavenlyActivePosition() {
    return Offset(dimensions.width / 2, dimensions.reckoningBarY - dimensions.heavenlyBeadRadius);
  }

  /// Calculates the inactive position for a heavenly bead (away from reckoning bar)
  Offset getHeavenlyInactivePosition() {
    return Offset(dimensions.width / 2, dimensions.heavenlyBeadRadius + dimensions.beadSpacing);
  }

  /// Calculates the active position for an earthly bead (against reckoning bar)
  /// [beadIndex] is the index of the earthly bead (0-3)
  Offset getEarthlyActivePosition(int beadIndex) {
    if (beadIndex < 0 || beadIndex > 3) {
      throw ArgumentError('Earthly bead index must be between 0 and 3');
    }

    return Offset(dimensions.width / 2, dimensions.reckoningBarY + dimensions.earthlyBeadRadius + (beadIndex * dimensions.beadSpacing));
  }

  /// Calculates the inactive position for an earthly bead (away from reckoning bar)
  /// [beadIndex] is the index of the earthly bead (0-3)
  Offset getEarthlyInactivePosition(int beadIndex) {
    if (beadIndex < 0 || beadIndex > 3) {
      throw ArgumentError('Earthly bead index must be between 0 and 3');
    }

    final baseY = dimensions.height - dimensions.earthlyBeadRadius - dimensions.beadSpacing;
    return Offset(dimensions.width / 2, baseY - (beadIndex * dimensions.beadSpacing));
  }

  /// Gets the target position for a bead based on its type, index, and desired state
  Offset getTargetPosition(BeadType type, int beadIndex, BeadPosition position) {
    switch (type) {
      case BeadType.heavenly:
        switch (position) {
          case BeadPosition.active:
            return getHeavenlyActivePosition();
          case BeadPosition.inactive:
            return getHeavenlyInactivePosition();
          case BeadPosition.moving:
            // For moving state, return current position (should be handled by caller)
            throw ArgumentError('Cannot calculate target position for moving state');
        }
      case BeadType.earthly:
        switch (position) {
          case BeadPosition.active:
            return getEarthlyActivePosition(beadIndex);
          case BeadPosition.inactive:
            return getEarthlyInactivePosition(beadIndex);
          case BeadPosition.moving:
            // For moving state, return current position (should be handled by caller)
            throw ArgumentError('Cannot calculate target position for moving state');
        }
    }
  }

  /// Determines if a position is within the valid bounds for a bead type
  bool isPositionValid(BeadType type, Offset position) {
    // Check horizontal bounds
    final radius = type == BeadType.heavenly ? dimensions.heavenlyBeadRadius : dimensions.earthlyBeadRadius;
    if (position.dx < radius || position.dx > dimensions.width - radius) {
      return false;
    }

    // Check vertical bounds based on bead type
    switch (type) {
      case BeadType.heavenly:
        return position.dy >= radius && position.dy <= dimensions.reckoningBarY - radius;
      case BeadType.earthly:
        return position.dy >= dimensions.reckoningBarY + radius && position.dy <= dimensions.height - radius;
    }
  }

  /// Constrains a position to be within valid bounds for a bead type
  Offset constrainPosition(BeadType type, Offset position) {
    final radius = type == BeadType.heavenly ? dimensions.heavenlyBeadRadius : dimensions.earthlyBeadRadius;

    // Constrain horizontal position
    final constrainedX = position.dx.clamp(radius, dimensions.width - radius);

    // Constrain vertical position based on bead type
    double constrainedY;
    switch (type) {
      case BeadType.heavenly:
        constrainedY = position.dy.clamp(radius, dimensions.reckoningBarY - radius);
        break;
      case BeadType.earthly:
        constrainedY = position.dy.clamp(dimensions.reckoningBarY + radius, dimensions.height - radius);
        break;
    }

    return Offset(constrainedX, constrainedY);
  }

  /// Determines the appropriate position state based on current position
  BeadPosition determinePositionState(BeadType type, Offset currentPosition) {
    final snapThreshold = dimensions.beadSpacing; // Distance threshold for snapping

    switch (type) {
      case BeadType.heavenly:
        final activePos = getHeavenlyActivePosition();
        final inactivePos = getHeavenlyInactivePosition();

        final distanceToActive = (currentPosition - activePos).distance;
        final distanceToInactive = (currentPosition - inactivePos).distance;

        if (distanceToActive < snapThreshold && distanceToActive <= distanceToInactive) {
          return BeadPosition.active;
        } else if (distanceToInactive < snapThreshold) {
          return BeadPosition.inactive;
        } else {
          return BeadPosition.moving;
        }

      case BeadType.earthly:
        // For earthly beads, we need to check against all possible positions
        // We'll use the closest active/inactive position for comparison
        double minActiveDistance = double.infinity;
        double minInactiveDistance = double.infinity;

        for (int i = 0; i < 4; i++) {
          final activePos = getEarthlyActivePosition(i);
          final inactivePos = getEarthlyInactivePosition(i);

          final distanceToActive = (currentPosition - activePos).distance;
          final distanceToInactive = (currentPosition - inactivePos).distance;

          if (distanceToActive < minActiveDistance) {
            minActiveDistance = distanceToActive;
          }
          if (distanceToInactive < minInactiveDistance) {
            minInactiveDistance = distanceToInactive;
          }
        }

        if (minActiveDistance < snapThreshold && minActiveDistance <= minInactiveDistance) {
          return BeadPosition.active;
        } else if (minInactiveDistance < snapThreshold) {
          return BeadPosition.inactive;
        } else {
          return BeadPosition.moving;
        }
    }
  }

  /// Finds the closest snap position for a bead
  Offset findClosestSnapPosition(BeadType type, int beadIndex, Offset currentPosition) {
    switch (type) {
      case BeadType.heavenly:
        final activePos = getHeavenlyActivePosition();
        final inactivePos = getHeavenlyInactivePosition();

        final distanceToActive = (currentPosition - activePos).distance;
        final distanceToInactive = (currentPosition - inactivePos).distance;

        return distanceToActive <= distanceToInactive ? activePos : inactivePos;

      case BeadType.earthly:
        final activePos = getEarthlyActivePosition(beadIndex);
        final inactivePos = getEarthlyInactivePosition(beadIndex);

        final distanceToActive = (currentPosition - activePos).distance;
        final distanceToInactive = (currentPosition - inactivePos).distance;

        return distanceToActive <= distanceToInactive ? activePos : inactivePos;
    }
  }
}
