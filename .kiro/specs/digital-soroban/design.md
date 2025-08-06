# Design Document

## Overview

The digital soroban application will be built using Flutter's custom painting and gesture detection capabilities to create an authentic Japanese abacus experience. The app will feature a traditional soroban layout with smooth multi-touch interactions, realistic bead physics, and customizable appearance options.

The core architecture follows a Model-View-Controller pattern with reactive state management, where the soroban state is managed centrally and UI components respond to state changes through Flutter's built-in state management.

## Architecture

### High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Presentation  │    │    Business     │    │      Data       │
│     Layer       │◄──►│     Logic       │◄──►│     Layer       │
│                 │    │     Layer       │    │                 │
│ - SorobanWidget │    │ - SorobanModel  │    │ - Settings      │
│ - BeadWidget    │    │ - BeadModel     │    │ - Preferences   │
│ - CustomPainter │    │ - GestureLogic  │    │ - Themes        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Component Structure

- **SorobanApp**: Main application widget with theme and routing
- **SorobanScreen**: Primary screen containing the soroban interface
- **SorobanWidget**: Custom widget that renders the complete soroban
- **RodWidget**: Individual rod containing heavenly and earthly beads
- **BeadWidget**: Individual bead with gesture detection and animation
- **SorobanPainter**: Custom painter for drawing the soroban frame and rods
- **SorobanController**: State management for bead positions and interactions

## Components and Interfaces

### Core Models

#### SorobanModel
```dart
class SorobanModel {
  final int numberOfRods;
  final List<RodModel> rods;
  final SorobanTheme theme;
  final SorobanSettings settings;
  
  // Methods for rod management and state persistence
}
```

#### RodModel
```dart
class RodModel {
  final int index;
  final bool isUnitRod; // Every third rod has a dot marker
  final BeadModel heavenlyBead; // go-dama (value: 5)
  final List<BeadModel> earthlyBeads; // ichi-dama (value: 1 each)
}
```

#### BeadModel
```dart
class BeadModel {
  final BeadType type; // heavenly or earthly
  final int value; // 5 for heavenly, 1 for earthly
  bool isActive; // touching the reckoning bar
  Offset position;
  AnimationController animationController;
}
```

### UI Components

#### SorobanWidget
- Custom widget that orchestrates the entire soroban display
- Handles overall layout and responsive design
- Manages multi-touch gesture detection across all rods
- Coordinates animations and state updates

#### RodWidget
- Renders individual rods with proper spacing and alignment
- Contains one heavenly bead and four earthly beads
- Displays unit rod markers (dots) on every third rod
- Handles rod-specific gesture interactions

#### BeadWidget
- Individual bead rendering with biconal shape
- Gesture detection for drag operations
- Smooth animation between active/inactive positions
- Visual feedback during interactions (shadows, highlights)

#### SorobanPainter
- Custom painter for drawing the soroban frame
- Renders the reckoning bar (horizontal divider)
- Draws rod lines and unit markers
- Applies theme-based styling and materials

### Gesture System

#### Multi-Touch Support
- Uses Flutter's `GestureDetector` with `onPanStart`, `onPanUpdate`, `onPanEnd`
- Implements custom hit-testing to identify which bead is being touched
- Supports simultaneous interaction with multiple beads across different rods
- Prevents interference between concurrent gestures

#### Bead Movement Logic
- **Drag Detection**: Identifies when a bead is being dragged
- **Snap Zones**: Defines areas where beads automatically snap to position
- **Collision Detection**: Prevents beads from overlapping inappropriately
- **Latching Mechanism**: Locks beads in active/inactive positions

## Data Models

### Bead Positioning System

#### Coordinate System
- Origin at top-left of each rod
- Heavenly bead moves vertically in upper section
- Earthly beads move vertically in lower section
- Reckoning bar acts as the reference line for active positions

#### Position States
```dart
enum BeadPosition {
  active,    // Against reckoning bar (counting position)
  inactive,  // Away from reckoning bar (resting position)
  moving     // Currently being dragged
}
```

#### Animation Curves
- **Snap Animation**: `Curves.elasticOut` for natural settling
- **Drag Following**: `Curves.linear` for immediate response
- **Return Animation**: `Curves.easeInOut` for smooth return to position

### Theme System

#### Material Themes
```dart
enum SorobanMaterial {
  traditionalWood,
  darkWood,
  marble,
  plastic,
  bamboo
}
```

#### Visual Properties
- Bead colors and textures
- Frame and rod materials
- Shadow and lighting effects
- Unit marker styling

### Settings Model
```dart
class SorobanSettings {
  int numberOfRods; // 7, 13, 21, 23, 27, or 31
  SorobanMaterial material;
  double animationSpeed; // 0.5x to 2.0x
  double touchSensitivity; // Drag threshold
  bool soundEnabled;
  bool hapticEnabled;
  bool showUnitMarkers;
}
```

## Error Handling

### Gesture Conflicts
- **Multiple Touch Detection**: Prevent single bead from responding to multiple touches
- **Invalid Positions**: Ensure beads cannot be placed in impossible positions
- **Animation Interruption**: Handle cases where new gestures interrupt ongoing animations

### State Consistency
- **Position Validation**: Verify bead positions are within valid ranges
- **State Recovery**: Restore valid state if corruption is detected
- **Memory Management**: Properly dispose of animation controllers and listeners

### Device Compatibility
- **Screen Size Adaptation**: Handle various screen sizes and orientations
- **Performance Optimization**: Maintain 60fps on lower-end devices
- **Touch Precision**: Adapt touch targets for different screen densities

## Testing Strategy

### Unit Tests
- **Model Logic**: Test bead position calculations and state transitions
- **Animation Logic**: Verify animation curves and timing
- **Settings Management**: Test configuration persistence and validation
- **Gesture Processing**: Test touch event interpretation and response

### Widget Tests
- **Bead Rendering**: Verify correct visual representation of beads
- **Layout Responsiveness**: Test adaptation to different screen sizes
- **Gesture Recognition**: Test touch interaction detection and handling
- **Animation Smoothness**: Verify smooth transitions and proper timing

### Integration Tests
- **Multi-Touch Scenarios**: Test simultaneous bead manipulation
- **State Persistence**: Verify settings and positions are saved/restored
- **Performance Testing**: Ensure smooth operation under various conditions
- **Accessibility**: Test with screen readers and accessibility tools

### Visual Testing
- **Theme Consistency**: Verify all themes render correctly
- **Animation Quality**: Ensure smooth, natural-looking movements
- **Cross-Platform**: Test visual consistency across iOS, Android, and web
- **Device Variations**: Test on various screen sizes and pixel densities

## Implementation Considerations

### Performance Optimization
- Use `RepaintBoundary` widgets to isolate repaints to individual beads
- Implement efficient hit-testing to minimize gesture processing overhead
- Cache painted elements where possible to reduce custom painting costs
- Use `AnimatedBuilder` for efficient animation updates

### Accessibility
- Implement semantic labels for screen readers
- Provide alternative interaction methods for users with motor impairments
- Ensure sufficient color contrast for visual accessibility
- Support voice-over descriptions of bead positions

### Platform-Specific Features
- **iOS**: Utilize haptic feedback through `HapticFeedback.lightImpact()`
- **Android**: Implement material design ripple effects for touch feedback
- **Web**: Optimize for mouse and touch interactions
- **Desktop**: Support keyboard navigation and shortcuts

### State Management
- Use `ChangeNotifier` for reactive state updates
- Implement proper disposal of resources to prevent memory leaks
- Cache frequently accessed calculations for performance
- Provide undo/redo functionality for educational purposes