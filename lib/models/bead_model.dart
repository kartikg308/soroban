import 'package:flutter/material.dart';

/// Enum representing the type of bead in the soroban
enum BeadType {
  heavenly, // go-dama (value: 5)
  earthly, // ichi-dama (value: 1)
}

/// Enum representing the position state of a bead
enum BeadPosition {
  active, // Against reckoning bar (counting position)
  inactive, // Away from reckoning bar (resting position)
  moving, // Currently being dragged
}

/// Exception thrown when an invalid bead state transition is attempted
class InvalidBeadTransitionException implements Exception {
  final String message;
  final BeadPosition fromState;
  final BeadPosition toState;

  const InvalidBeadTransitionException(this.message, this.fromState, this.toState);

  @override
  String toString() => 'InvalidBeadTransitionException: $message (from $fromState to $toState)';
}

/// Model representing an individual bead in the soroban
class BeadModel {
  final BeadType type;
  final int value;
  BeadPosition _position;
  Offset _currentOffset;
  AnimationController? _animationController;

  BeadModel({required this.type, required this.value, BeadPosition position = BeadPosition.inactive, Offset currentOffset = Offset.zero}) : _position = position, _currentOffset = currentOffset;

  /// Gets the current position state of the bead
  BeadPosition get position => _position;

  /// Gets the current offset position of the bead
  Offset get currentOffset => _currentOffset;

  /// Gets the animation controller for this bead
  AnimationController? get animationController => _animationController;

  /// Checks if the bead is currently active (against the reckoning bar)
  bool get isActive => _position == BeadPosition.active;

  /// Checks if the bead is currently being moved
  bool get isMoving => _position == BeadPosition.moving;

  /// Sets the position state of the bead with validation
  void setPosition(BeadPosition newPosition) {
    if (!_isValidTransition(_position, newPosition)) {
      throw InvalidBeadTransitionException('Invalid transition from $_position to $newPosition', _position, newPosition);
    }
    _position = newPosition;
  }

  /// Sets the position state of the bead without validation (for internal use)
  void _setPositionUnchecked(BeadPosition newPosition) {
    _position = newPosition;
  }

  /// Validates if a state transition is allowed
  bool _isValidTransition(BeadPosition from, BeadPosition to) {
    // Same state is always valid
    if (from == to) return true;

    // Define valid transitions
    switch (from) {
      case BeadPosition.inactive:
        // From inactive, can go to moving or active
        return to == BeadPosition.moving || to == BeadPosition.active;
      case BeadPosition.active:
        // From active, can go to moving or inactive
        return to == BeadPosition.moving || to == BeadPosition.inactive;
      case BeadPosition.moving:
        // From moving, can go to active or inactive
        return to == BeadPosition.active || to == BeadPosition.inactive;
    }
  }

  /// Checks if a transition to the given position is valid
  bool canTransitionTo(BeadPosition newPosition) {
    return _isValidTransition(_position, newPosition);
  }

  /// Updates the current offset position of the bead
  void updateOffset(Offset newOffset) {
    _currentOffset = newOffset;
  }

  /// Sets the animation controller for this bead
  void setAnimationController(AnimationController? controller) {
    _animationController = controller;
  }

  /// Creates a copy of this bead model with optional parameter overrides
  BeadModel copyWith({BeadType? type, int? value, BeadPosition? position, Offset? currentOffset, AnimationController? animationController}) {
    final copy = BeadModel(type: type ?? this.type, value: value ?? this.value, position: position ?? _position, currentOffset: currentOffset ?? _currentOffset);
    copy.setAnimationController(animationController ?? _animationController);
    return copy;
  }

  /// Creates a copy with a new position, bypassing validation (for internal use)
  BeadModel _copyWithPositionUnchecked(BeadPosition position) {
    final copy = BeadModel(type: type, value: value, position: _position, currentOffset: _currentOffset);
    copy._setPositionUnchecked(position);
    copy.setAnimationController(_animationController);
    return copy;
  }

  /// Disposes of resources used by this bead model
  void dispose() {
    _animationController?.dispose();
    _animationController = null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BeadModel && other.type == type && other.value == value && other._position == _position && other._currentOffset == _currentOffset;
  }

  @override
  int get hashCode {
    return type.hashCode ^ value.hashCode ^ _position.hashCode ^ _currentOffset.hashCode;
  }

  @override
  String toString() {
    return 'BeadModel(type: $type, value: $value, position: $_position, offset: $_currentOffset)';
  }
}
